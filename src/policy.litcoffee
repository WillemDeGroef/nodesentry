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

                wrapWithMembrane: (libName) -> false

        disable: (lib) -> this

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

            strEqual = (fullName) -> (rule) -> fullName == rule.apiCall

            areType = (t) ->
                (rule) -> rule instanceof t

            conditionsAreTrue = (dTgt, ret) ->
                (rule) ->
                    _.chain(rule.conditions)
                        .map (cond) -> cond(dTgt, ret) == true
                        .reduce ((memo, c) -> memo and c), true
                        .value()

            doGetActions = (dTgt, args...) ->
                (rule) ->
                    _.chain(rule.actions)
                        .map (action) -> action.apply(this, [dTgt].concat(args))
                    return rule

            calcRetValue = (origRet, rule) ->
                rule.ret(origRet)

            isEmpty = (l) -> l.size().value() == 0
            isNotFunction = (v) -> typeof v != "function"

            @policy.onGet = (wTgt, name, wRec, dTgt, ret, fullName) =>
                name = name.toString()
                if fullName == undefined
                    fullName = "#{dTgt.constructor.name.toString()}.#{name}"

                relevantRules = _.chain(@rules)
                    .filter(strEqual(fullName))
                console.log "onGet name: " + name
                # console.log "dTgt constructo name: " + dTgt.constructor.name.toString()
                console.log "onGet fullName: " + fullName.toString()

                onRules = relevantRules.filter(areType(OnRule))
                # console.log onRules

                onGetValue = onRules.filter(conditionsAreTrue(dTgt, ret))
                    .map(doGetActions(dTgt, ret))
                    .reduce(calcRetValue, ret)
                    .value()

            @policy.functionCall = (dTgt, dryThis, dryArgs, calcResult, fullName) =>
                console.log("fullname: %s", fullName)
                if dryThis != undefined and fullName.indexOf("/") != -1
                    fullName = "#{dryThis.constructor.name}.#{dTgt.name}"
                relevantRules = _.chain(@rules).filter(strEqual(fullName))

                onRules = relevantRules.filter(areType(OnRule))

                util = require('util')
                # console.log "Checking the special thing: name : %s, dryThis: %s", dTgt.name, util.inspect(dTgt, {showProxy: true})
                # if (dTgt instanceof Function)
                #     console.log dTgt.toString()
                # if ((dTgt.name == "valueOf" || dTgt.name == "toString") && dryThis != undefined && (dryThis instanceof Number || dryThis instanceof Boolean || dryThis instanceof Symbol || dryThis instanceof String))
                #     console.log "Doing the special thing"
                #     result = calcResult()
                #     console.log "Result: " + result
                #     actualResult = onRules.filter(conditionsAreTrue(dTgt, result))
                #         .map(doGetActions(dTgt, result))
                #         .reduce(calcRetValue, result)
                #         .value()
                #     console.log "actualresult: " + actualResult
                #     return () -> actualResult

                console.log "calcResult before onGetValue"
                console.log (util.inspect(calcResult, {showProxy: true}))

                onGetValue = onRules.filter(conditionsAreTrue(dTgt, calcResult))
                # onGetValue = onRules.filter(conditionsAreTrue([dTgt].concat(dryArgs), calcResult))
                    .map(doGetActions(dTgt, calcResult))
                    .reduce(calcRetValue, calcResult)
                    .value()


                # console.log "calcResult to String"
                # console.log calcResult.toString()
                # console.log "rules"
                # console.log @rules[0].ret.toString()
                # Use the modified value that .on generated as actual function.
                # This will have wrapped Reflect.apply .
                calcResult = onGetValue
                # console.log "calcResult to String after onGetValue: " + calcResult.toString()

                beforeRules = relevantRules.filter(areType(BeforeRule))
                afterRules = relevantRules.filter(areType(AfterRule))

                console.log "calcResult before filter"
                console.log (util.inspect(calcResult, {showProxy: true}))
                calcResult = beforeRules.filter(conditionsAreTrue(dTgt, dryArgs))
                    .map(doGetActions(dryThis, dTgt, dryArgs, calcResult))
                    .reduce(calcRetValue, calcResult)
                    .value()

                # return as function because the generic membrane will invoke it afterwards
                ->
                    # console.log "if this is just before the error..."
                    # console.log "Information: fullname: %s; dTgt.name: %s; dryThis.constructor.name: %s", fullName, dTgt.name, dryThis.constructor.name
                    console.log (util.inspect(calcResult, {showProxy: true}))
                    console.log "Doing calcResult now"
                    ret = calcResult()
                    afterRules.filter(conditionsAreTrue(dTgt, ret))
                        .map(doGetActions(dryThis, dTgt, dryArgs, ret))
                        .reduce(calcRetValue, ret)
                        .value()

            @policy


    class Rule
        constructor: (@apiCall, @parent) ->

List of actions with side effects [0..n]:

            @actions = []

The default return function [1..1]:

            @ret = (v) -> v

A list of conditions that evaluate to `true` or `false` [1..n]:

            @conditions = [ -> true]

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





    module.exports = Policy
