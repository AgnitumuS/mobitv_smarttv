module.exports = function (grunt) {
  grunt.registerTask ('prod',[
    // 'pre-dev'
    'prepareAssest',
    'prepareProd',
    'sails-linker:prodJs',
    'sails-linker:prodCss',
    'sync'
  ]);
};
