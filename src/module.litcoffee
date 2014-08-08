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

        constructor: (@libName, @dirName) ->
            @origRequire = require
            @origMod = require "module"
            @policyObj = {}

            resolvedModule = @origMod._resolveLookupPaths @libName, undefined
            paths = @origMod._nodeModulePaths(".").concat(resolvedModule[1])
            @fileName = @origMod._findPath(@libName, paths) if not @isBuiltInModule()

        setPolicy: (@policyObj) ->

Return `true` if we know for sure that the requested library is a built-in library.

        isBuiltInModule: () ->
            ["child_process", "cluster", "crypto", "dns",
             "domain", "events", "fs", "http", "https", "net",
             "os", "path", "dgram", "url", "vm"].indexOf(@libName) > -1

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
