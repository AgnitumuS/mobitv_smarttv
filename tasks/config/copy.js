config = require('../config.js');
module.exports = function (grunt) {
  grunt.config.set('copy', {
    healthCheck :{
      files :[
        {
          expand: true,
          cwd: './',
          src: ['health_check'],
          dest: 'public'
        }
      ]
    },
    assets: {
      files: [
        {
          expand: true,
          cwd: 'app/assets',
          src: ['**/*'],
          dest: 'public'
        },
        {
          expand: true,
          cwd: 'app/styles',
          src: ['**/*','!**/*.scss'],
          dest: 'public/styles'
        }
      ]
    }
  });

  grunt.loadNpmTasks('grunt-contrib-copy');
};
