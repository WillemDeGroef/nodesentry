Policy
======

TODO: Builder object for a policy.

    class Policy
        constructor: () ->
            @policy =

Indicate if a given library (name) should be wrapped in a separate membrane. If
a policy doesn't talk about a specific depending library, then it there is no
need for it to be wrapped. Therefor, the default return value is `false`:

                mustWrap: (libName) -> false


                onGet: (wTgt, name, wRec, dTgt, ret) -> ret

        build: () ->
            @policy


     module.exports = Policy
