should = require 'should'
Module = require "../src/module"
Policy = require "../src/policy"

describe "Policy", () ->
    beforeEach () =>
        @policy = new Policy()

    it "should return a default policy", () =>
        p = @policy.build()
        p.mustWrap("bleh").should.be.false
        p.onGet({}, "", {}, {}, 1234).should.equal 1234

    it.skip "should modify return values", ->
    it.skip "should call external functions", ->
    it.skip "should throw errors", ->
    it.skip "should sequence actions", ->
    it.skip "should sequence rules", ->

