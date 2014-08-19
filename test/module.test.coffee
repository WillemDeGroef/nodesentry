should = require 'should'
Module = require "../src/module"
Policy = require "../src/policy"

describe "Module", () ->
    beforeEach =>
        @policy = new Policy()
        @module = new Module("../test/circle.js")
        @module.setPolicy @policy

    it "should return a module object", =>
        @module.should.be.type "object"

    it "should load the library", =>
        @module.loadLibrary.should.be.type "function"

        publicAPI = @module.loadLibrary()
        publicAPI.should.be.an.Object
        publicAPI.should.have.properties ["area", "circumference"]

    it "should allow calls to public API", =>
        circle = @module.loadLibrary()
        circle.area(10).should.be.approximately 314, 1

    it "should allow calls to public API depending on libraries", =>
        circle = @module.loadLibrary()
        circle.test().should.be.above 1

     it "should intercept calls to public API", (done) =>
        @policy.on("area").do(-> done())
        m = new Module("../test/circle.js")
        m.setPolicy @policy.build()

        circle = m.loadLibrary()
        circle.area(10).should.be.approximately 314, 1

     it "should intercept calls to depending libraries", (done) =>
        @policy.on("test").do(-> done())
        @module = new Module("../test/circle.js")
        @module.setPolicy @policy.build()

        circle = @module.loadLibrary()
        circle.test().should.be.above 1

    it "should work with buffers through membranes", =>
        b = new Buffer("hello")
        circle = @module.loadLibrary()
        circle.handle_buffer(b).should.be.equal "hello"

    it "should receive buffers through membranes", =>
        circle = @module.loadLibrary()
        b = circle.get_buffer()
        b.constructor.name.should.be.equal "Buffer"
        b.toString().should.be.equal "hello"
        Buffer.isBuffer(b).should.be.true
