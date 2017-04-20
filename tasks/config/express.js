config = require('../config.js');
var port = process.env.PORT
  ? process.env.PORT
  : 1343;
module.exports = function (grunt) {

  grunt.config.set('express', {
    options: {
      port: port
    },
    dev: {
      options: {
        script: config.APP_SCRIPT
      }
    }
  });
  grunt.loadNpmTasks('grunt-express-server');
};