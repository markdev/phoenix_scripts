# /bin/bash

# Must start at the initialize directory
cd ../..

# # Set script variables
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

# Add brunch-config.js
subl "$MYDIR"
echo "Now it's time to fix brunch-config.js"
echo "Open brunch-config.js and apply the changes at the bottom"
echo "Are you finished? [Yes|No]"
read FINISHED

# launch server
echo "Ok, now let's test it!"
iex -S mix phoenix.server



# # Here shall go the users and user auth

# # email

# # avatar/ex_aws