module.exports = function (grunt) {
  grunt.config.set('sync', {
    dev: {
      updateAndDelete: true,
      files: [
        {
          cwd: 'public',
          src: ['**/*'],
          dest: 'www'
        }
      ]
    }
  });

  grunt.loadNpmTasks('grunt-sync');
};
