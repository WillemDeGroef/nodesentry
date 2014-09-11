    vm = require "vm"
    path = require "path"
    _ = require "underscore"
    Membrane = require "./membrane"

    class WrappedModule

        constructor: (@libName, @modulePaths, @policyObj) ->
            @modModule = (require "module")
            @fileName = @modModule._findPath @libName, @modulePaths
            @requestLib = @fileName || @libName
            @builtIn = @requestLib.indexOf(".js") == -1
            @pathName = path.dirname @fileName

        load: (requireFunc = @membranedRequire) ->
            throw new Error "`require` must be a function" if typeof requireFunc != "function"
            module.paths = [@pathName].concat(@modModule._nodeModulePaths(@pathName))

            if @builtIn
                r = require @requestLib
            else
                wrappedMod = new @modModule(@libName, this)
                wrappedMod.require = requireFunc
                wrappedMod.load @requestLib
                r = wrappedMod.exports


Return a membraned variant of the public API interface.

            return r if not @policyObj
            return new Membrane(r, @policyObj, @requestLib) if (typeof r) == "function"
            return @wrapObjectWithMembrane(@requestLib.replace(".js",""), r)


        membranedRequire: (libName) =>
            mod = new WrappedModule libName, module.paths, @policyObj
            
            return require(libName) if mod.builtIn or not @policyObj?.wrapWithMembrane?(libName)

Lets load the new `Module` for the requested library.

            return mod.load()

The last step is to create a wrapper function that will carefully wrap each
exported API call within a membrane.

            @wrapObjectWithMembrane(libName, libexports)

        wrapObjectWithMembrane: (libName, obj) ->
            _.object(_.map obj, @buildMembraneWrapper libName)

        buildMembraneWrapper: (libName) =>
            (propObj, propName) => [propName, new Membrane(propObj, @policyObj, "#{libName}.#{propName}")]

    module.exports = WrappedModule
