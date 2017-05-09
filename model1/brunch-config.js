exports.config = {
  // files: {
  //   javascripts: {
  //     joinTo: "js/app.js"
  //   },
  //   stylesheets: {
  //     joinTo: "css/app.css",
  //     order: {
  //       after: ["web/static/css/app.css"] // concat app.css last
  //     }
  //   },
  //   templates: {
  //     joinTo: "js/app.js"
  //   }
  // },
  files: {
    javascripts: {
      joinTo: {
        "js/app.js": /^(web\/static\/js)|(node_modules)/,
        "js/ex_admin_common.js": ["web/static/vendor/ex_admin_common.js"],
        "js/admin_lte2.js": ["web/static/vendor/admin_lte2.js"],
        "js/jquery.min.js": ["web/static/vendor/jquery.min.js"],
      }
    },
    stylesheets: {
      joinTo: {
        "css/app.css": /^(web\/static\/css)|^(web\/static\/scss)|(node_modules)/,
        "css/admin_lte2.css": ["web/static/vendor/admin_lte2.css"],
        "css/active_admin.css.css": ["web/static/vendor/active_admin.css.css"],
      },
      order: {
        after: ["web/static/css/app.css"] // concat app.css last
      }
    },
    templates: {
      joinTo: "js/app.js"
    }
  },

  conventions: {
    // This option sets where we should place non-css and non-js assets in.
    assets: /^(web\/static\/assets)/
  },

  // Phoenix paths configuration
  paths: {
    // Dependencies and current project directories to watch
    watched: [
      "web/static",
      "test/static"
    ],

    // Where to compile files to
    public: "priv/static"
  },

  // Configure your plugins
  plugins: {
    babel: {
      // Do not use ES6 compiler in vendor code
      ignore: [/(web\/static\/vendor)|node_modules/]
    },
    sass: {
      options: {
        includePaths: [
          "node_modules/bootstrap-sass/assets/stylesheets",
          "node_modules/font-awesome/scss",
          "node_modules/toastr"
        ], // tell sass-brunch where to look for files to @import
      },
      precision: 8 // minimum precision required by bootstrap-sass
    },
    copycat: {
      "fonts": [
        "node_modules/bootstrap-sass/assets/fonts/bootstrap",
        "node_modules/font-awesome/fonts"
      ] // copy these files into priv/static/fonts/
    }
  },

  modules: {
    autoRequire: {
      "js/app.js": [
        "web/static/js/app",
        "web/static/js/theme-app"
      ]
    }
  },

  npm: {
    enabled: true,
    globals: {
      $: 'jquery',
      jQuery: 'jquery'
    },
    styles: {
      "bootstrap-table": ["dist/bootstrap-table.css"],
      "jquery-ui": ["themes/base/all.css"]
    } // included these styles into the build
  }
}
