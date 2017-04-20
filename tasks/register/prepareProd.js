module.exports = function (grunt) {
  grunt.registerTask('prepareProd', [
    'concat',
    'uglify',
    'autoprefixer',
    'cssmin'
  ]);
};
