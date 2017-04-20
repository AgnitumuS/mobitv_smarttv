module.exports = function(grunt) {

    grunt.config.set('sass', {
        convert: {
            options: {
                lineNumbers: true,
                sourceMap: false
            },
            files: [{
                expand: true,
                cwd: 'app/styles/',
                src: ['**/*.scss'],
                dest: 'public/styles',
                ext: '.css'
            }]
        }
    });

    grunt.loadNpmTasks('grunt-contrib-sass');
};