# /bin/bash

# Must start at the initialize directory
cd ../..

# Set script variables
MYDIR=$(pwd)
PSCRIPTPATH=$(echo "$MYDIR"/phoenix_scripts/model1)

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

# In here shall go the mix deps.get dependency
# https://stackoverflow.com/questions/38972736/how-to-select-lines-between-two-patterns

# Installations
mix ecto.create
mix ecto.migrate
npm install

# Here shall go the users and user auth

# email

# avatar/ex_aws