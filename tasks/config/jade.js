config = require('../config.js');
var list = {};
list['.public/index.html'] = ["app/index.jade"];
module.exports = function (grunt) {
  grunt.config.set('jade', {
    templates: {
      options: {
        pretty: true
      },
      files: [
        {
          expand: true,
          cwd: 'app',
          src: ['**/*.jade'],
          dest: 'public/template',
          ext: '.html'
        },
        {
          expand: true,
          cwd: 'app/views',
          src: ['**/*.jade'],
          dest: 'public/',
          ext: '.html'
        }
      ]
    }
  })
  ;
  grunt.loadNpmTasks('grunt-contrib-jade');
};
