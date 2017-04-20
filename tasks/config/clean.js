module.exports = function (grunt) {
  grunt.config.set('clean', {
    public: ['public','www'],
    orig :['**/*.orig']
  });

  grunt.loadNpmTasks('grunt-contrib-clean');
};
