module.exports = function (grunt) {

  grunt.config.set('coffee', {
    compile: {
      expand: true,
      cwd: 'app',
      src: ['**/*.coffee'],
      dest: 'public/js',
      ext: '.js'
    }
  });

  grunt.loadNpmTasks('grunt-contrib-coffee');
};
