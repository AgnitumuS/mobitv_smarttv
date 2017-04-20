config = require('../config.js');

module.exports = function (grunt) {
  pkg = grunt.file.readJSON('package.json');
  grunt.config.set('uglify', {

    minFile: {
      options: {
        compress: {
          drop_console: true
        },
        mangle: true,
        banner: '/*! <%= pkg.name %> - v<%= pkg.version %> - <%= grunt.template.today("dd-mm-yyyy") %> */'
      },
      files: {
        'public/script.min.js': ['public/min/script.min.js']
      }
    }

  });

  grunt.loadNpmTasks('grunt-contrib-uglify');
};
