var config = require('../config.js');
module.exports = function (grunt) {
  grunt.config.set('sails-linker', {
    devJs: {
      options: {
        startTag: '<!-- SCRIPTS-->',
        endTag: '<!-- SCRIPTS END-->',
        fileTmpl: "<script type='text/javascript' src='" + config.serverPath + "%s'></script>",
        appRoot: 'public/'
      },
      files: {
        'public/*.html': config.prefix(config.jsfiles, 'public')
      }
    },
    devCss: {
      options: {
        startTag: '<!-- STYLES-->',
        endTag: '<!-- STYLES END-->',
        fileTmpl: "<link rel='stylesheet' href='" + config.serverPath + "%s'/>",
        appRoot: 'public/'
      },
      files: {
        'public/*.html': config.prefix(config.cssfiles, 'public')
      }
    },
    prodCss: {
      options: {
        startTag: '<!-- STYLES-->',
        endTag: '<!-- STYLES END-->',
        fileTmpl: '<link rel="stylesheet" href="' + config.serverPath + '%s"/>',
        appRoot: 'public/'
      },
      files: {
        'public/*.html': 'public/styles/styles.min.css'
      }
    },
    prodJs: {
      options: {
        startTag: '<!-- SCRIPTS-->',
        endTag: '<!-- SCRIPTS END-->',
        fileTmpl: "<script type='text/javascript' src='" + config.serverPath + "%s'></script>",
        appRoot: 'public/'
      },
      files: {
        'public/*.html': 'public/script.min.js'
      }
    }
  });
  grunt.loadNpmTasks('grunt-sails-linker');
};