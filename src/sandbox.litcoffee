Sandbox
=======

    vm = require "vm"
    path = require "path"
    _ = require "underscore"
    Membrane = require "./membrane"

    class Sandbox
        constructor: (@fileName, @policyObj) ->

            @origRequire = require
            @glob =
                __filename: @fileName
                __dirname: path.dirname(@fileName)
                console: console
                module:
                    exports: {}
                Buffer: Buffer
                require: undefined
                process: process

            @glob.global = @glob
            @glob.GLOBAL = @glob
            @glob.exports = @glob.module.exports

        buildContext: () ->
            ctxt = vm.createContext @glob
            customRequire = @buildMembranedRequire()
            ctxt.require = (libName) -> customRequire libName
            return ctxt

        buildMembranedRequire: ->
            (libName) =>
                try
                    # first try to load library as a global library or add cwd if local file
                    libName = path.join(@glob.__dirname, libName) if @glob.__dirname? and libName.indexOf(".js") > -1
                    libexports = @origRequire libName
                catch e
                    # otherwise try to look in cwd node_modules directory
                    libName = path.join(path.join(@glob.__dirname, "node_modules"), libName)
                    libexports = @origRequire libName


If the library is only used within the (outer) membrane, i.e., it is not
referenced in the policy, we return immediately.

                try
                    return libexports unless @policyObj.mustWrap(libName)
                catch e
                    return libexports

The last step is to create a wrapper function that will carefully wrap each
exported API call within a membrane.

                f =  @buildMembraneWrapper libName
                return _.object(_.map libexports, f)

        buildMembraneWrapper: (libName) =>
            (propObj, propName) =>
                name = "#{libName}.#{propName}"
                [propName, new Membrane(propObj, @policyObj)]

        context: => @sandboxedContext ?= @buildContext()
        global: => @glob


    module.exports = Sandbox
