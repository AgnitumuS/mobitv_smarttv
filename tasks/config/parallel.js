module.exports = function (grunt) {
  grunt.config.set('parallel', {
    dev: {
      options: {
        grunt: true
      },
      tasks: [
        'coffee:compile',
        'jade:templates',
        'jade:index',
        'sass:convert',
        'copy:assets'
      ]
    }
  });

  grunt.loadNpmTasks('grunt-parallel');
};
