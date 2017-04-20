module.exports = function (grunt) {
  grunt.registerTask('pre-dev-watch', [
    'sails-linker:devJs',
    'sails-linker:devCss',
    'sync'

  ]);
  grunt.registerTask('pre-dev', [
    'prepareAssest',
    'pre-dev-watch'
  ]);
  grunt.registerTask('dev', [
    'pre-dev',
    'express:dev',
    'watch'
  ]);
};
