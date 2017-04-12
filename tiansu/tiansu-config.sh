# /bin/bash

cp brunch-config.js ../../brunch-config.js
echo "brunch-config.js copied";

cp app.js ../../web/static/js/app.js
echo "app.js copied";

mkdir ../../web/static/scss

cp app.scss ../../web/static/scss/app.scss
echo "app.scss copied";

cp package.json ../../package.json
echo "package.json copied";
