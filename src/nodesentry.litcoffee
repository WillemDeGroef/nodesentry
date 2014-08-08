# NodeSentry

    harmony = require "harmony-reflect"
    log = require "./logger"
    Module = require "./module"
    origRequire = require

Introduce a `safe_require` method that load a library with the accompanying
security policy (i.e., an memory handler as defined in the original membrane
implementation).

    global.safe_require = (libName, policyObj) ->
        if policyObj?
            m = new Module(libName)
            m.setPolicy policyObj
            m.loadLibrary()
        else
            origRequire libName

Overwrite the original `require` with its safe variant.

    global.require = global.safe_require

