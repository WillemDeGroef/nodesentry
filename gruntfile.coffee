###
NodeSentry

Licensed under the MIT license
For full copyright and license information, please see the LICENSE file

@author         Willem De Groef <Willem.DeGroef@cs.kuleuven.be>
@copyright      2014 -- iMinds-DistriNet, KU Leuven
@link           https://github.com/WillemDeGroef/nodesentry
@license        MIT License
###

module.exports = ( grunt ) ->

    jsonFile = grunt.file.readJSON  # Read a json file
    define = grunt.registerTask     # Register a local task
    log = grunt.log.writeln         # Write a single line to STDOUT

    config =
        srcDir: 'src'        # CoffeeScript or other source files to be compiled or processed
        tstDir:  'test/'      # Project's tests
        resDir: 'res/'        # Static resources - images, text files, external deps etc.
        libDir: 'lib'
        srcFiles: ['<%= srcDir %>**/*.litcoffee']
        tstFiles: '<%= tstDir %>**/*.test.coffee'
        pkg: jsonFile 'package.json'

        watch:
            options:
                tasks: ['lint', 'test']
                interrupt: true
                atBegin: true
                dateFormat:         ( time ) -> log "Done in #{time}ms"

            gruntfile:
                files: 'gruntfile.coffee'
                tasks: '<%= watch.options.tasks %>'

            project:
                files: ['<%= srcFiles %>', '<%= tstFiles %>']
                tasks: '<%= watch.options.tasks %>'

        coffeelint:
            options: jsonFile 'coffeelint.json'

            gruntfile: 'gruntfile.coffee'
            project: ['<%= srcFiles %>', '<%= tstFiles %>']

        mochacli:
            options:
                reporter: 'spec'
                require: ['should']
                compilers: ['coffee:coffee-script/register']
                harmony: true

            project:
                src: ['<%= tstFiles %>']

        coffee:
            build:
                expand: true
                ext: '.js'
                src: ['*.litcoffee']
                cwd: '<%= srcDir %>'
                dest: '<%= libDir %>'

        uglify:
            build:
                files: [
                    expand: true
                    src: '<%= libDir %>**/*.js'
                ]
                options:
                    banner:'/*\nNodeSentry v<%= pkg.version %>\nCopyright 2014 -- iMinds-DistriNet, KU Leuven\n*/\n'

        clean:
            build: ['<%= libDir %>**/*.js']
            docs: ['<%= docDir %>']

    require( 'load-grunt-tasks' )( grunt )

    define 'lint',          ['coffeelint']
    define 'test',          ['mochacli']
    define 'build:dev',     ['clean:build', 'lint', 'coffee:build', 'test']
    define 'build',         ['build:dev', 'uglify:build']
    define 'default',       ['build']

    grunt.initConfig config
