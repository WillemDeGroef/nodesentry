    vm = require "vm"
    path = require "path"
    _ = require "underscore"
    Membrane = require "./membrane"
    Require = require


    class WrappedModule

        constructor: (@libName, @modulePaths, @policyObj) ->
            @modModule = (require "module")
            @module = new  @modModule(@libName, this)
            @fileName = @modModule._findPath @libName, @modulePaths
            @pathName = path.dirname @fileName

        load: (requireFunc = @membranedRequire) ->
            throw new Error "`require` must be a function" if typeof requireFunc != "function"
            module.paths = [@pathName].concat(@modModule._nodeModulePaths(@pathName))
            @module.require = requireFunc
            @module.load @fileName
            r = @module.exports


Return a membraned variant of the public API interface.

            return r if not @policyObj
            return new Membrane(r, @policyObj, r.toString()) if (typeof r) == "function"
            return @wrapObjectWithMembrane(@fileName.replace(".js",""), r) if (typeof r) == "object"
            throw new Error "unimplemented case in #{__filename}"


        membranedRequire: (libName) =>
            mod = new WrappedModule libName, module.paths, @policyObj
            if not mod.fileName or @policyObj?.skip?(libName)
                libexports = Require libName
            else

Lets load the new `Module` for the requested library.

                libexports = mod.load @membranedRequire

If the library is only used within the (outer) membrane, i.e., it is not
referenced in the policy, we return immediately.

            return libexports unless @policyObj?.mustWrap?(libName)

The last step is to create a wrapper function that will carefully wrap each
exported API call within a membrane.

            @wrapObjectWithMembrane(libName, libexports)

        wrapObjectWithMembrane: (libName, obj) ->
            _.object(_.map obj, @buildMembraneWrapper libName)

        buildMembraneWrapper: (libName) =>
            (propObj, propName) => [propName, new Membrane(propObj, @policyObj, "#{libName}.#{propName}")]

    module.exports = WrappedModule
