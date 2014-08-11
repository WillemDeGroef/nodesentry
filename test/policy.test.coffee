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

    it "should work with rules", () =>
        p = @policy.build()
        p.mustWrap("bleh").should.be.false
        p.onGet({}, "", {}, {}, 1234).should.equal 1234

