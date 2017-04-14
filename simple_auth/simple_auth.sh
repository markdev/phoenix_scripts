# /bin/bash
cd ../..
SEDSTRONE=$(sed '9q;d' config/config.exs)
LOWER=$(echo $SEDSTRONE | awk -F ':|,' '{print $2}')

SEDSTRTWO=$(sed '33q;d' web/web.ex) 
UPPER=$(echo $SEDSTRTWO | awk -F 'alias|Repo' '{print $2}' | sed 's/.$//')
cd -

# Create the user model
cd ../..
mix phoenix.gen.model User users email:string name:string password_hash:string is_admin:boolean
# add null: false
sed -i '' '6s/$/, null: false/' $(pwd)/$(find priv/repo/migrations/ -name "*create_user*")
# add create unique_index
sed -i '' '12s/$/\
      create unique_index(:users, [:email])/' $(pwd)/$(find priv/repo/migrations/ -name "*create_user*")

# Create posts model
mix phoenix.gen.model Post posts title:string body:text user_id:references:users

# modify user model
sed -i '' '6s/$/\
    field :password, :string, virtual: true/' $(pwd)/$(find web/models/user.ex)
sed -i '' '9s/$/\
    has_many :posts, MyApplication.Post/' $(pwd)/web/models/user.ex
sed -i '' "s|MyApplication|${UPPER}|g" $(pwd)/web/models/user.ex
sed -i '' '14s/$/\
  @required_fields ~w(email)a\
  @optional_fields ~w(name is_admin)a\
/' $(pwd)/$(find web/models/user.ex)

# modify post model
sed -i '' '18s/$/\
    |> assoc_constraint(:user)/' $(pwd)/$(find web/models/post.ex)
sed -i '' '11s/$/\
\
  @required_fields ~w(title)a\
  @optional_fields ~w(body)a\
/' $(pwd)/$(find web/models/post.ex)
cd -

# Add user controller
cp web/controllers/user_controller.ex $(pwd)/../../web/controllers/user_controller.ex
sed -i '' "s|MyApplication|${UPPER}|g" $(pwd)/../../web/controllers/user_controller.ex

# Add routes
sed -i '' '19s|$|\
\
    resources "/users", UserController, only: [:show, :new, :create]\
  |' $(pwd)/../../web/router.ex

# Copy partials
cp web/views/user_view.ex $(pwd)/../../web/views/user_view.ex
sed -i '' "s|MyApplication|${UPPER}|g" $(pwd)/../../web/views/user_view.ex
mkdir -p $(pwd)/../../web/templates/user
cp web/templates/user/show.html.eex $(pwd)/../../web/templates/user/show.html.eex
cp web/templates/user/new.html.eex $(pwd)/../../web/templates/user/new.html.eex

# Add registration link
sed -i '' "19s|.*|            <%= link \"Register\", to: user_path(@conn, :new) %>|g" $(pwd)/../../web/templates/layout/app.html.eex

# Add comeonin dependency
sed -i '' "22s|:postgrex|:postgrex, :comeonin|g" $(pwd)/../../mix.exs
sed -i '' '40s|]$|,\
     {:comeonin, "~> 2.5"}]|g' $(pwd)/../../mix.exs
cd ../..
mix deps.get
cd -

# Add changeset functions
sed -i '' '23s/.*/    |> cast(params, @required_fields ++ @optional_fields)/g' $(pwd)/../../web/models/user.ex
sed -i '' '24s/.*/    |> validate_required(@required_fields)/g' $(pwd)/../../web/models/user.ex
sed -i '' '25s/$/\
\
  def registration_changeset(struct, params) do\
    struct\
    |> changeset(params)\
    |> cast(params, ~w(password)a, [])\
    |> validate_length(:password, min: 6, max: 100)\
    |> hash_password\
  end\
\
  defp hash_password(changeset) do\
    case changeset do\
      %Ecto.Changeset{valid?: true,\
                      changes: %{password: password}} ->\
        put_change(changeset,\
                   :password_hash,\
                   Comeonin.Bcrypt.hashpwsalt(password))\
      _ ->\
        changeset\
    end\
  end\
  /g' $(pwd)/../../web/models/user.ex

sed -i '' '13s/.*/    changeset = %User{} |> User.registration_changeset(user_params)\
\
    case Repo.insert(changeset) do\
      {:ok, user} ->\
        conn\
        |> put_flash(:info, "#{user.name} created!")\
        |> redirect(to: user_path(conn, :show, user))\
      {:error, changeset} ->\
        render(conn, "new.html", changeset: changeset)\
    end/g' $(pwd)/../../web/controllers/user_controller.ex

sed -i '' '3s/$/\
  plug :scrub_params, "user" when action in [:create]\
/g' $(pwd)/../../web/controllers/user_controller.ex

# Authentication and Sessions
sed -i '' '21s|$|\
\
    resources "/sessions", SessionController, only: [:new, :create, :delete]\
  |' $(pwd)/../../web/router.ex

cp web/controllers/session_controller.ex $(pwd)/../../web/controllers/session_controller.ex
sed -i '' "s|MyApplication|${UPPER}|g" $(pwd)/../../web/controllers/session_controller.ex

cp web/views/session_view.ex $(pwd)/../../web/views/session_view.ex
sed -i '' "s|MyApplication|${UPPER}|g" $(pwd)/../../web/views/session_view.ex

mkdir -p $(pwd)/../../web/templates/session
cp web/templates/session/new.html.eex $(pwd)/../../web/templates/session/new.html.eex

# Add Links
sed -i '' '19s/.*/            <li>\
              <%= link "Register", to: user_path(@conn, :new) %>\
            <\/li>\
            <li>\
              <%= link "Sign in", to: session_path(@conn, :new) %>\
            <\/li>/g' $(pwd)/../../web/templates/layout/app.html.eex


#####################
Add guardian dependency
sed -i '' '41s|]$|,\
     {:guardian, "~> 0.12.0"}]|g' $(pwd)/../../mix.exs
cd ../..
mix deps.get
cd -

sed -i '' '24s/$/\
# Configures Guardian\
config :guardian, Guardian,\
 issuer: "MyApplication.#{Mix.env}",\
 ttl: {30, :days},\
 verify_issuer: true,\
 serializer: MyApplication.GuardianSerializer,\
 secret_key: to_string(Mix.env) <> "SuPerseCret_aBraCadabrA"\
/g' $(pwd)/../../config/config.exs
sed -i '' "s|MyApplication|${UPPER}|g" $(pwd)/../../config/config.exs

mkdir -p $(pwd)/../../web/auth
cp web/auth/guardian_serializer.ex $(pwd)/../../web/auth/guardian_serializer.ex
sed -i '' "s|MyApplication|${UPPER}|g" $(pwd)/../../web/auth/guardian_serializer.ex

# Add Links
sed -i '' '10s/$/\
\
  defp login(conn, user) do\
    conn\
    |> Guardian.Plug.sign_in(user)\
  end\
/g' $(pwd)/../../web/controllers/session_controller.ex

sed -i '' '9s/.*/   # try to get user by unique email from DB\
    user = Repo.get_by(User, email: email)\
    # examine the result\
    result = cond do\
      # if user was found and provided password hash equals to stored\
      # hash\
      user \&\& checkpw(password, user.password_hash) ->\
        {:ok, login(conn, user)}\
      # else if we just found the use\
      user ->\
        {:error, :unauthorized, conn}\
      # otherwise\
      true ->\
        # simulate check password hash timing\
        dummy_checkpw\
        {:error, :not_found, conn}\
    end\
    case result do\
      {:ok, conn} ->\
        conn\
        |> put_flash(:info, "You’re now logged in!")\
        |> redirect(to: page_path(conn, :index))\
      {:error, _reason, conn} ->\
        conn\
        |> put_flash(:error, "Invalid email\/password combination")\
        |> render("new.html")\
    end\
/g' $(pwd)/../../web/controllers/session_controller.ex

sed -i '' '2s/$/\
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]\
  alias MyApplication.User\
/g' $(pwd)/../../web/controllers/session_controller.ex

sed -i '' "s|MyApplication|${UPPER}|g" $(pwd)/../../web/controllers/session_controller.ex

cp web/auth/current_user.ex $(pwd)/../../web/auth/current_user.ex
sed -i '' "s|MyApplication|${UPPER}|g" $(pwd)/../../web/auth/current_user.ex

sed -i '' '15s/$/\
  pipeline :with_session do\
    plug Guardian.Plug.VerifySession\
    plug Guardian.Plug.LoadResource\
    plug MyApplication.CurrentUser\
  end\
/g' $(pwd)/../../web/router.ex
sed -i '' "s|MyApplication|${UPPER}|g" $(pwd)/../../web/router.ex

sed -i '' 's/pipe_through :browser/pipe_through [:browser, :with_session]/g' $(pwd)/../../web/router.ex

sed -i '' '49s/$/\
\
  defp logout(conn) do\
    Guardian.Plug.sign_out(conn)\
  end\
/g' $(pwd)/../../web/controllers/session_controller.ex

sed -i '' '48s/.*/    conn\
      |> logout\
      |> put_flash(:info, "See you later!")\
      |> redirect(to: page_path(conn, :index))/g' $(pwd)/../../web/controllers/session_controller.ex

sed -i '' '19,25d' $(pwd)/../../web/templates/layout/app.html.eex 
sed -i '' '18s/$/\
            <%= if @current_user do %>\
              <li><%= @current_user.email %> (<%= @current_user.id %>)<\/li>\
              <li>\
                <%= link "Sign out", to: session_path(@conn, :delete,\
                                                      @current_user),\
                                     method: "delete" %>\
              <\/li>\
            <% else %>\
              <li><%= link "Register", to: user_path(@conn, :new) %><\/li>\
              <li><%= link "Sign in", to: session_path(@conn, :new) %><\/li>\
            <% end %>/g' $(pwd)/../../web/templates/layout/app.html.eex 

