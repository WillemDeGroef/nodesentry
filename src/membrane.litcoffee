# Membrane

In order to maintain control over all references acquired by the library,
e.g., via a call to "require", NodeSentry applies the membrane pattern,
originally proposed by Miller[^15] and further refined by Van Cutsem and
Miller[^23]. The goal of a membrane is to fully isolate two object graphs.
Intuitively, a membrane creates a shadow object that is a “clone” of the target
object that it wishes to protect. Only the references to the shadow
object are passed further to callers. Any access to the shadowed object is then
intercepted and either served directly or eventually reflected on the target
object through handlers. In this way, when a membrane revokes a reference,
essentially by destroying the shadow object, it instantly achieves the
goal of transitively revoking all references as advocated by Miller.

    class Membrane

        constructor: (@wetTarget, @policyObj, @name) ->
            return makeGenericMembrane(@wetTarget, @policyObj, @name).target
            

Currently we rely on a slightly modified version of the 
[original implementation](https://github.com/tvcutsem/harmony-reflect/blob/master/examples/generic_membrane.js)
of Van Cutsem.

    originalFile = "../res/generic_membrane.js"
    makeGenericMembrane = require(originalFile).makeGenericMembrane

The external API only consists of a `Membrane` class.

    module.exports = Membrane


[^15]: M. S. Miller. Robust Composition: Towards a Unified Approach to Access
Control and Concurrency Control. PhD thesis, Johns Hopkins University,
Baltimore, Maryland, USA, May 2006

[^23]: T. Van Cutsem and M. S. Miller. Trustworthy Proxies: Virtualizing
Objects with Invariants. In Proceedings of the European Conference on
Object-Oriented Programming (ECOOP), pages 154–178, 2013

