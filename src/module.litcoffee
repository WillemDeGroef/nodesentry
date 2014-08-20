Module
======

Acts as a replacement for the original module. Works by loading a given library
in a sandbox (to apply lower-bound policies) and wraps each public API also in
a membrane (to apply upper-bound policies)


    path = require "path"
    vm = require "vm"
    fs = require "fs"

    Sandbox = require "./sandbox"
    Membrane = require "./membrane"


    class Module

        constructor: (@libName) ->
            @policyObj = {}
            @fileName = require.resolve(@libName)

        setPolicy: (@policyObj) ->

Return `true` if we know for sure that the requested library is a built-in library.

        isBuiltInModule: () -> @fileName.indexOf(".js") == -1

Load the library and return a wrapped version of the original public API:

        loadLibrary: () ->

            requireCode = "module.exports = require('#{@libName}');"
            requireCode = fs.readFileSync(@fileName).toString() unless @isBuiltInModule()

            script = vm.createScript requireCode

Load in an instrumented sandbox to enforce lower-bound policies:

            ctxt = new Sandbox(@fileName, @policyObj).context()
            script.runInContext ctxt

Apply a membrane on the public API of the library to enforce upper-bound policies:

            new Membrane(ctxt.module.exports, @policyObj)


    module.exports = Module
