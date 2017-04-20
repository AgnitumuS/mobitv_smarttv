var SERVER = '/';
if (process.env.ENV == "staging") {
  var SERVER = 'https://staging-movies.fimplus.io/smarttv/';
}
if (process.env.ENV == "production") {
  var SERVER = 'https://movies.fimplus.io/smarttv/';
}

if (process.env.SERVER) {
  SERVER = process.env.SERVER;
} else {
  process.env.SERVER = SERVER
}
var config = {
  APP_SCRIPT: 'app.js',
  serverPath: SERVER,
  prefix: function (data, prefix) {
    return data.map(function (path) {
      return prefix + '/' + path;
    });
  },
  cssfiles: [
    'css/bootstrap.css',
    'css/bootstrap-theme.css',
    'css/**/*.css',
    'styles/**/*.css'
  ],
  jsfiles: [
    'libs/underscore-min.js',
    'libs/moment.js',
    'libs/moment-timezone.js',
    'libs/jquery.min.js',
    'libs/angular.min.js',
    'libs/*',
    'player_web/**/*.js',
    'js/templates.js',
    'js/**/*.js'
  ]

};
module.exports = config;