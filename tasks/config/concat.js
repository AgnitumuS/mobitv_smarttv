config = require('../config.js');
module.exports = function (grunt) {
  grunt.config.set('concat', {
    files: {
      files: {
        'public/min/script.min.js': config.prefix(config.jsfiles, 'public'),
        'public/min/styles.min.css': config.prefix(config.cssfiles, 'public'),
      }
    }
  })
  ;

  grunt.loadNpmTasks('grunt-contrib-concat');
};
