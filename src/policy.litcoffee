Policy
======

    class Policy
        constructor: () ->
            @rules = []
            @libsToWrap = []
            @policy =

Indicate if a given library (name) should be wrapped in a separate membrane. If
a policy doesn't talk about a specific depending library, then it there is no
need for it to be wrapped. Therefor, the default return value is `false`:

                mustWrap: (libName) -> false
                onGet: (wTgt, name, wRec, dTgt, ret) -> ret


        on: (name) ->
            child = new Rule name, this
            # check if (lib, call) = name must be added to libsToWrap
            # iff lib[0].toLowerCase() == lib[0]
            @rules.push child
            child

        before: (name) ->
            child = new Rule name, this
            @rules.push child
            child

The `build` method generates the whole structure of our semantic model of the membrane object.

        build: () =>
            @libsToWrap = []
            @policy.onGet = (wTgt, name, wRec, dTgt, ret) =>
                funcCall = "#{dTgt.constructor.name.toString()}.#{name}"
                ret = rule.action(dTgt, ret) for rule in @rules when funcCall.indexOf(rule.apiCall) > -1 and rule.condition(dTgt, ret)
                return ret
                
            @policy



    class Rule
        constructor: (@apiCall, @parent) ->
            @action = (tgt, ret) -> ret
            @condition = -> true

        call: (f) =>
            @action = (dTgt, ret) ->
                f(dTgt, ret)
                return  ret
            this

        return: (v) =>
            oldAction = @action
            @action = (dTgt, ret) ->
                oldAction?(dTgt, ret)
                return v
            this

        throw: (err) =>
            @action = (dTgt, ret) -> throw new Error err
            this

        if: (cond) =>
            @condition = (dtgt, ret) -> cond(dtgt, ret)
            this

        and: (cond) =>
            @condition = (dtgt, ret) => @condition(dtgt, ret) && cond(dtgt, ret)
            this

        or: (cond) =>
            @condition = (dtgt, ret) => @condition(dtgt, ret) || cond(dtgt, ret)
            this


        on: (name) ->
            return @parent.on name

        before: (name) ->
            return @parent.before name

        build: () ->
            @parent.build()

     module.exports = Policy
