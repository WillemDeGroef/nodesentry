should = require 'should'
require "../src"
Module = require "../src/module"
Policy = require "../src/policy"

describe "Policy", =>
    @policy = null

    beforeEach =>
        @policy = new Policy()

    it "should return a default policy", =>
        p = @policy.build()
        p.mustWrap("bleh").should.be.false
        p.onGet({}, "", {}, {}, 1234).should.equal 1234

    it "should modify return values", =>
        @policy.on("area").return((origArea) -> (r) -> 2*origArea(r))
        p = @policy.build()
        circle = safe_require "../test/circle.js", p
        circle.area(1).should.approximately 6, 1

    it "should call external functions", (done) =>
        @policy.on("area") .do(-> done())
        p = @policy.build()
        circle = safe_require "../test/circle.js", p
        circle.area(1).should.be.approximately 3, 1


    it.skip "should throw errors", =>
        @policy.on("area").throw("this thing should throw")
        p = @policy.build()
        circle = safe_require "../test/circle.js", p
        circle.area(1).should.throw


    it "should sequence actions", (done) =>
        beenCalled = false
        seq1 = => @beenCalled = true
        seq2 = => done() if @beenCalled

        @policy.on("area")
            .do(seq1)
            .do(seq2)

        circle = safe_require "../test/circle.js", @policy.build()
        circle.area(1).should.be.approximately 3, 1



    it "should sequence rules", (done) =>
        beenCalled = false
        seq1 = => @beenCalled = true
        seq2 = => done() if @beenCalled

        @policy
            .on("area")
                .do(seq1)
            .on("area")
                .do(seq2)

        circle = safe_require "../test/circle.js", @policy.build()
        circle.area(1).should.be.approximately 3, 1



