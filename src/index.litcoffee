NodeSentry
==========

The key idea of our proposal, called \ns, is to use a variant of an inline
reference monitor~\cite{schneider2000,erlingsson2003} as modified for the
Security-by-Contract approach for Java and {.NET}~\cite{desmet2008} in order to
make it more flexible. Specifically, we do not embed the monitor into the code as
suggested by most approaches for inline reference monitors but inline only 
hooks in a few key places, while the monitor itself is an external component. In our
case this has the added advantage of potentially improving performance (a key
requirement for server-side code) as the monitor can now run in a separate
thread and threads that do not call security relevant actions are unaffected.
Further, and maybe most important, we do not limit ourselves to purely
raising security exceptions and stopping the execution but support policies
that specify how to ``fix'' the execution; the ability to continue executing after
security errors is an essential requirement
for server-side applications.

In order to maintain control over all references acquired by the library, e.g.,
via a call to \jslib{require}, \ns applies the \emph{membrane} pattern,
originally proposed by Miller~\cite[\S 9]{miller2006} and further refined
by Van Cutsem and Miller~\cite{vancutsem2013}. The goal of a membrane is to fully isolate two object
graphs~\cite{miller2006,vancutsem2013}.  Intuitively, a membrane creates a
shadow object that is a ``clone'' of the target object that it wishes to
protect. Only the references to the shadow
object are passed further to callers. Any access to the shadowed object is then
intercepted and either served directly or eventually reflected on the target
object through handlers. In this way, when a membrane revokes a reference,
essentially by destroying the shadow object~\cite{vancutsem2013}, it instantly
achieves the goal of transitively revoking all references as advocated by
Miller~\cite{miller2006}.


    harmonyFlagsEnabled = -> "function" == typeof Map
    throw new Error "NodeSentry requires the harmony flags. (`node --harmony`)" if not harmonyFlagsEnabled()
    
    harmony = require "harmony-reflect"
    log = require "./logger"
    WrappedModule = require "./module"
    path = require "path"

    absolutePath = (name) -> name[0] == "/"
    installedModule = (name) -> not (name.indexOf(".js") > -1) and not (name.indexOf(".") > -1)
    updatePath = (name) -> path.join(path.dirname(module.parent.filename), name)

    global.safe_require = (libName, policyObj) ->
        libName = updatePath(libName) unless absolutePath(libName) or installedModule(libName)
        modPaths = module.parent.paths

Load the module in a specific `ModuleLoader` that makes it possible to intercept all subsequent calls to `require`.

        wrappedModule = new WrappedModule(libName, modPaths, policyObj)
        do wrappedModule.load

    module.exports.Policy = require "./policy"

Copyright 2014 -- iMinds-DistriNet, KU Leuven
