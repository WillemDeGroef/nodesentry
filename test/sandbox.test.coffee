should = require 'should'
Sandbox = require "../src/sandbox"
Policy = require "../src/policy"
Module = require "../src/module"

describe "Sandbox", () ->
    beforeEach =>
        @policyObj = new Policy().build()
        @policyObj.mustWrap("os").should.be.false
        @sandbox = new Sandbox(__filename, @policyObj)

    it "should return a context object", =>
        @sandbox.should.be.type "object"

    it "should not have the default `require` function", =>
        (typeof @sandbox.require).should.equal "undefined"

    it "should have a correct global object", =>
        @sandbox.global().should.have.properties ["global", "process", "console"]
        @sandbox.global().should.have.properties ["Buffer", "require", "__filename"]
        @sandbox.global().should.have.properties ["__dirname", "module", "exports"]

    it.skip "should introduce timeouts and intervals in global object", =>
        @sandbox.global().should.have.properties ["setTimeout", "clearTimeout", "setInterval", "clearInterval"]


    it "should build a context for a script", =>
        ctxt = @sandbox.buildContext()
        ctxt.should.be.type "object"
        ctxt.require.should.be.type "function"

    it "should have a shielded context", =>
        @sandbox.context().should.be.type "object"
        @sandbox.context().should.equal @sandbox.context()
        @sandbox.context().should.have.properties ["module", "process"]

    it "should intercept library loads", =>
        f = @sandbox.buildMembraneWrapper("test")
        f.should.be.type "function"


    it "should implement a wrapper for require", =>
        os = require "os"
        osstr = Object.getOwnPropertyNames(os).toString()

        @sandbox.buildMembranedRequire().should.be.type "function"

        memreq = @sandbox.buildMembranedRequire()
        mros = memreq "os"
        mros.should.not.be.Array
        mros.should.be.Object
        Object.getOwnPropertyNames(mros).toString().should.equal osstr

    it "should apply membranes with require wrapper", (done) =>
        c = require("./circle.js")
        cstr = Object.getOwnPropertyNames(c).toString()

        @policyObj.mustWrap = -> true
        @policyObj.functionCall = (dryTarget, dryThis, dryArgs) ->
            done()
            Reflect.apply(dryTarget, dryThis, dryArgs)

        memreq = @sandbox.buildMembranedRequire()
        mc = memreq "./circle.js"
        mc.should.be.Object

        mcstr = Object.getOwnPropertyNames(mc).toString()
        cstr.should.equal mcstr
        mc.area(1).should.be.approximately 3, 1

    it "should allow original behavior through membraned require", =>
        memreq = @sandbox.buildMembranedRequire()
        mc = memreq "./circle.js"

        mc.area(1).should.be.approximately 3, 1
        mc.test().should.be.above 1






    
