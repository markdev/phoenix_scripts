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
sed -i '' '7s/$/, virtual: true/' $(pwd)/$(find web/models/user.ex)
sed -i '' '8s/$/\
      has_many :posts, SimpleAuth.Post/' $(pwd)/$(find web/models/user.ex)
sed -i '' '13s/$/\
\
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
sed -i '' "s|MyApplication|${UPPER}|g" $(pwd)/$(find web/controllers/user_controller.ex)

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









