module.exports = function (grunt) {
  grunt.config.set('jst', {
    options: {
      prettify: true,
      namespace: 'Templates',
      processName: function (filePath) {
        return filePath.replace('public/template/', '').replace(/(\.html$)/, '').replace(/\//g, '.').replace('.view', '');
      }
    },
    convert: {
      files: {
        'public/js/templates.js': ['public/template/**/*.html'],
      }
    }
  });
  grunt.loadNpmTasks('grunt-contrib-jst');
};
