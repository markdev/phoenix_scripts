# /bin/bash

cp brunch-config.js ../../brunch-config.js
echo "brunch-config.js copied";

cp app.js ../../web/static/js/app.js
echo "app.js copied";

mkdir ../../web/static/scss

cp app.scss ../../web/static/scss/app.scss
echo "app.scss copied";

npm uninstall --save-dev babel-brunch
npm uninstall --save-dev brunch
npm uninstall --save-dev clean-css-brunch
npm uninstall --save-dev javascript-brunch
npm uninstall --save-dev uglify-js-brunch

npm install --save autoprefixer@6.4.0
npm install --save babel-brunch@6.0.5
npm install --save bootstrap-sass@3.3.6
npm install --save bootstrap-table
npm install --save brunch@2.8.2
npm install --save clean-css-brunch
npm install --save css-brunch
npm install --save font-awesome@4.6.3
npm install --save javascript-brunch
npm install --save jquery@2.2.1
npm install --save jquery-ui@1.12.0
npm install --save postcss-brunch@0.6.0
npm install --save sass-brunch
npm install --save toastr@2.1.2
npm install --save uglify-js-brunch
npm install --save-dev babel-preset-es2015@6.13.2
