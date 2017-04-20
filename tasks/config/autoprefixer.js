module.exports = function (grunt) {
  grunt.config.set('autoprefixer', {
    options: {
      browsers: ['opera 12', 'ff 15', 'chrome 25'],
      diff: 'public/css/styles'

    },
    dev: {
      src: 'public/styles/style.css',
      dest: 'public/styles/style.css'
    }
  });

  grunt.loadNpmTasks('grunt-autoprefixer');
};
