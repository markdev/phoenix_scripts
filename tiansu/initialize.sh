# /bin/bash

# initialize git
cd ../..
git init
printf '%s\n%s\n' '# Phoenix_scripts' '/phoenix_scripts' >> .gitignore
git add .
git commit -m "Initial commit"
cd -

cp brunch-config.js ../../brunch-config.js
echo "brunch-config.js copied";

cp app.js ../../web/static/js/app.js
echo "app.js copied";

mkdir ../../web/static/scss

cp app.scss ../../web/static/scss/app.scss
echo "app.scss copied";

cp index.html.eex ../../web/templates/page/index.html.eex
echo "index.html.eex copied";

cp package.json ../../package.json
echo "package.json copied";

cd ../..
mix ecto.create
npm install
mix phoenix.server
