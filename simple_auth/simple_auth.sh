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
    has_many :posts, SimpleAuth.Post/' $(pwd)/$(find web/models/user.ex)
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
sed -i '' "19s|.*|						<%= link \"Register\", to: user_path(@conn, :new) %>|g" $(pwd)/../../web/templates/layout/app.html.eex

# Add comeonin dependency
sed -i '' "22s|:postgrex|:postgrex, :comeonin|g" $(pwd)/../../mix.exs
sed -i '' '40s|]$|,\
     {:comeonin, "~> 2.5"}]|g' $(pwd)/../../mix.exs
cd ../..
mix deps.get
cd -

#Add changeset functions
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

sed -i '' '13s/.*/		changeset = %User{} |> User.registration_changeset(user_params)\
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






