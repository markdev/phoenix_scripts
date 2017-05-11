# /bin/bash

# Must start at the initialize directory
cd ../..

# Set script variables
MYDIR=$(pwd)
PSCRIPTPATH=$(echo "$MYDIR"/phoenix_scripts/model1)

SEDSTRONE=$(sed '9q;d' config/config.exs)
LOWER=$(echo $SEDSTRONE | awk -F ':|,' '{print $2}')

SEDSTRTWO=$(sed '33q;d' web/web.ex) 
UPPER=$(echo $SEDSTRTWO | awk -F 'alias|Repo' '{print $2}' | sed 's/.$//')


# Hide phoenix_scripts
echo "" >> .gitignore
echo "# phoenix_scripts don't belong here" >> .gitignore
echo "/phoenix_scripts" >> .gitignore
git init && git add . && git commit -m "Initial commit of Phoenix app"

# Add License
curl http://www.apache.org/licenses/LICENSE-2.0.txt > LICENSE
git add LICENSE && git commit -m "Add Apache License 2.0"

# Tiansu's configuration
mkdir -p "$MYDIR"/web/static/scss
cp "$PSCRIPTPATH"/brunch-config.js "$MYDIR"/brunch-config.js 
cp "$PSCRIPTPATH"/app.js "$MYDIR"/web/static/js/app.js
cp "$PSCRIPTPATH"/app.scss "$MYDIR"/web/static/scss/app.scss
cp "$PSCRIPTPATH"/index.html.eex "$MYDIR"/web/templates/page/index.html.eex
cp "$PSCRIPTPATH"/package.json "$MYDIR"/package.json
cd "$MYDIR" && git add . && git commit -m "Adds Tiansu front-end configuration"

# Installations
mix deps.get
mix ecto.create
mix ecto.migrate
npm install


########################
# Including this to test coherence
# TODO remove from final script
mix phoenix.gen.html Post posts title:string body:text

sed -i '' '17s|$|\
\
    resources "/posts", PostController|g' "$MYDIR"/web/router.ex

mix ecto.migrate
########################


# Add coherence dependency
sed -i  '' 's|}]|},\
   	 {:coherence, "~> 0.3"}]|g' "$MYDIR"/mix.exs

sed -i  '' '22s|]]|, :coherence]]|g' "$MYDIR"/mix.exs

mix deps.get
mix coherence.install --full --rememberable --invitable --trackable


# Add to web/router.ex
sed -i '' '23s|$|\
  # Add this block\
  scope "/" do\
    pipe_through :browser\
    coherence_routes\
  end\
\
  # Add this block\
  scope "/" do\
    pipe_through :protected\
    coherence_routes :protected\
  end|g' "$MYDIR"/web/router.ex

sed -i '' '11s|$|\
  pipeline :protected do\
    plug :accepts, ["html"]\
    plug :fetch_session\
    plug :fetch_flash\
    plug :protect_from_forgery\
    plug :put_secure_browser_headers\
    plug Coherence.Authentication.Session, protected: true\
  end\
|g' "$MYDIR"/web/router.ex

sed -i '' '9s|$|\
    plug Coherence.Authentication.Session  # Add this|g' "$MYDIR"/web/router.ex

sed -i '' '2s|$|\
  use Coherence.Router|g' "$MYDIR"/web/router.ex


# Add User Seeds
echo "" >> "$MYDIR"/priv/repo/seeds.exs
echo "${UPPER}.Repo.delete_all ${UPPER}.User" >> "$MYDIR"/priv/repo/seeds.exs
echo "" >> "$MYDIR"/priv/repo/seeds.exs
echo "${UPPER}.User.changeset(%${UPPER}.User{}, %{name: \"Mark\", email: \"mark@end2endsites.com\", password: \"buddha83\", password_confirmation: \"buddha83\"})" >> "$MYDIR"/priv/repo/seeds.exs  
echo "|> ${UPPER}.Repo.insert!" >> "$MYDIR"/priv/repo/seeds.exs

# Migrate and run
mix ecto.migrate
mix run "$MYDIR"/priv/repo/seeds.exs

sed -i '' '44s|$|\
    resources "/posts", '"${UPPER}"'.PostController|g' "$MYDIR"/web/router.ex

sed -i '' '30d' "$MYDIR"/web/router.ex

#iex -S mix phoenix.server

# Add ex_admin dependency
# TODO: {:ex_admin, "~> 0.8"} with override
sed -i  '' 's|}]|},\
   	 {:ex_admin, github: "smpallen99/ex_admin"}]|g' "$MYDIR"/mix.exs

# Add ex_admin config
echo "" >> "$MYDIR"/config/config.exs
echo "config :ex_admin," >> "$MYDIR"/config/config.exs
echo "repo: $UPPER.Repo," >> "$MYDIR"/config/config.exs
echo "module: $UPPER," >> "$MYDIR"/config/config.exs    
echo "modules: [" >> "$MYDIR"/config/config.exs
echo "  $UPPER.ExAdmin.Dashboard," >> "$MYDIR"/config/config.exs
echo "]" >> "$MYDIR"/config/config.exs

# Install ex_admin
mix do deps.get, deps.compile
mix admin.install
git add . && git commit -m "installs ex_admin"

# Add ex_admin routes
sed -i '' '21s|$|\
  # your apps routes\
  scope "/admin", ExAdmin do\
    pipe_through :browser\
\
    admin_routes()\
  end|g' "$MYDIR"/web/router.ex

sed -i '' '2s|$|\
  use ExAdmin.Router|g' "$MYDIR"/web/router.ex

# Add ex_admin paging configuration
sed -i '' '2s|$|\
  use Scrivener, page_size: 10|g' "$MYDIR"/lib/"$LOWER"/repo.ex



#####################
# Add User to ex_admin 

mix admin.gen.resource User

sed -i '' '48s|$|\
  '"${UPPER}"'.ExAdmin.User|g' "$MYDIR"/config/config.exs

cp "$PSCRIPTPATH"/web/admin/user.ex  "$MYDIR"/web/admin/user.ex

sed -i '' "s|MyApplication|${UPPER}|g" "$MYDIR"/web/admin/user.ex

sed -i '' "24,28d" "$MYDIR"/web/router.ex

sed -i '' '23s|$|\
  scope "/admin", ExAdmin do\
    pipe_through :protected\
    admin_routes\
  end\
|g' "$MYDIR"/web/router.ex



# launch server
# iex -S mix phoenix.server

#######################
# Creating a bullshit authorization system
# TODO: Replace with Canary or something

#mix ecto.gen.migration add_admin_field_to_user
# create migration, add :admin, :boolean, default: false
# configure seeds, one admin, one not








# Here shall go the users and user auth

# email

# avatar/ex_aws