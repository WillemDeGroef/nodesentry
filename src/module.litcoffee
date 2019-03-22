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
            @absolute = @libName.indexOf("./") == -1
            @libName = path.basename @libName,".js"
            if @fileName != false
                @pathName = path.dirname @fileName
            else
                @pathName = ""

        load: (requireFunc = @membranedRequire) ->
            throw new Error "`require` must be a function" if typeof requireFunc != "function"
            module.paths = [@pathName].concat(@modModule._nodeModulePaths(@pathName))

            if @builtIn
                r = require @requestLib
            else
                wrappedMod = new @modModule(@libName, this)
                wrappedMod.require = requireFunc
                if @absolute
                    wrappedMod.load @requestLib
                else
                    wrappedMod.load @fileName
                r = wrappedMod.exports


Return a membraned variant of the public API interface.

            return r if not @policyObj
            return new Membrane(r, @policyObj, @requestLib) if (typeof r) == "function"
            return @wrapObjectWithMembrane(@libName.replace(".js",""), r)


        membranedRequire: (libName) =>
            mod = new WrappedModule libName, module.paths, @policyObj

            return require(libName) if mod.builtIn
            return require(mod.fileName) if not @policyObj?.wrapWithMembrane?(libName)

Lets load the new `Module` for the requested library.

            return mod.load()

The last step is to create a wrapper function that will carefully wrap each
exported API call within a membrane.

            @wrapObjectWithMembrane(libName, libexports)

        wrapObjectWithMembrane: (libName, obj) ->
            #_.object(_.map obj, @buildMembraneWrapper libName)
            new Membrane(obj, @policyObj, "#{libName}")

        buildMembraneWrapper: (libName) =>
            (propObj, propName) =>
                type = typeof propObj
                isPrimitive =  propObj == null || (type != "object" && type != "function")
                # if isPrimitive
                #   propObj = Object(propObj)
                    # console.log propName + " is primitive; type was " + type
                [propName, new Membrane(propObj, @policyObj, "#{libName}.#{propName}")]

    module.exports = WrappedModule
