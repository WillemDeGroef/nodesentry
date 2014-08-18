Policy
======

    _ = require "underscore"

    class Policy
        constructor: () ->
            @rules = []
            @libsToWrap = []

            @policy =

Indicate if a given library (name) should be wrapped in a separate membrane. If
a policy doesn't talk about a specific depending library, then it there is no
need for it to be wrapped. Therefor, the default return value is `false`:

                mustWrap: (libName) -> false

        on: (name) ->
            child = new OnRule name, this
            # check if (lib, call) = name must be added to libsToWrap
            # iff lib[0].toLowerCase() == lib[0]
            @rules.push child
            child

        before: (name) ->
            child = new BeforeRule name, this
            @rules.push child
            child

        after: (name) ->
            child = new AfterRule name, this
            @rules.push child
            child

The `build` method generates the whole structure of our semantic model of the membrane object.

        build: () =>
            @libsToWrap = []

            strEqual = (fullName) ->
                (rule) -> fullName.indexOf(rule.apiCall) > -1

            areType = (t) ->
                (rule) -> rule instanceof t

            conditionsAreTrue = (dTgt, ret) ->
                (rule) ->
                    _.chain(rule.conditions)
                        .map (cond) -> cond(dTgt, ret) == true
                        .reduce ((memo, c) -> memo and c), true
                        .value()

            doGetActions = (dTgt, ret) ->
                (rule) ->
                    _.chain(rule.actions)
                        .map (action) -> action(dTgt, ret)
                    return rule

            calcRetValue = (origRet, rule) -> rule.ret(origRet)

            isEmpty = (l) -> l.size().value() == 0
            isNotFunction = (v) -> typeof v != "function"

            @policy.onGet = (wTgt, name, wRec, dTgt, ret) =>
                fullName = "#{dTgt.constructor.name.toString()}.#{name}"
                relevantRules = _.chain(@rules)
                    .filter(strEqual(fullName))

                onRules = relevantRules.filter(areType(OnRule))
                beforeRules = relevantRules.filter(areType(BeforeRule))
                afterRules = relevantRules.filter(areType(AfterRule))

                onGetValue = onRules.filter(conditionsAreTrue(dTgt, ret))
                    .map(doGetActions(dTgt, ret))
                    .reduce(calcRetValue, ret)
                    .value()

                hasNoMoreRules = (isEmpty(beforeRules) and isEmpty(afterRules))

                return onGetValue if isNotFunction(onGetValue) or hasNoMoreRules

                return (() ->
                    beforeRules.filter(conditionsAreTrue(dTgt, ret))
                       .map(doGetActions(dTgt, ret))

                    afterRules.filter(conditionsAreTrue(dTgt, ret))
                        .map(doGetActions(dTgt, ret))
                        .reduce(calcRetValue, ret.apply(wRec, arguments))
                        .value()
                )

            @policy


    class Rule
        constructor: (@apiCall, @parent) ->

List of actions with side effects [0..n]:

            @actions = []

The default return function [1..1]:

            @ret = (v) -> v

A list of conditions that evaluate to `true` or `false` [1..n]:

            @conditions = [() -> true]

        do: (f) =>
            @actions.push f
            this

        return: (f) =>
            @ret = (v) -> f.call(this, v)
            this

        if: (cond) =>
            @conditions.push (dtgt, ret) -> cond(dtgt, ret)
            this

        on: (name) => @parent.on name
        before: (name) => @parent.before name
        after: (name) => @parent.after name
        build: () -> @parent.build()


    class OnRule extends Rule
    class AfterRule extends Rule

    class BeforeRule extends Rule
        return: (f) ->
            throw new Error "use Policy.on to mimic the required behavior"





    module.exports = Policy
