module.exports = function (grunt) {

  grunt.config.set('cssmin', {
    dist: {
      src: ['public/min/styles.min.css'],
      dest: 'public/styles/styles.min.css'
    }
  });

  grunt.loadNpmTasks('grunt-contrib-cssmin');
};
