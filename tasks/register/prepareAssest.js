module.exports = function (grunt) {
  grunt.registerTask('prepareAssest', [
    'clean',
    'coffee',
    'jade',
    'sass',
    'copy',
    'jst'
  ]);
};
