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
        @policy.on("PI").return((origPI) -> 3*origPI)
        circle = safe_require "../test/circle.js", @policy.build()
        circle.PI.should.approximately 9, 1

    it "should modify return values of functions", =>
        @policy.on("area").return((origArea) -> ((r) -> 2*origArea(r)))
        circle = safe_require "../test/circle.js", @policy.build()
        circle.area(1).should.approximately 6, 1

    it "should modify return values after function calls", =>
        @policy.after("area").return((origRes) -> 2*origRes)
        circle = safe_require "../test/circle.js", @policy.build()
        circle.area(1).should.approximately 6, 1

    it "should call external functions", (done) =>
        @policy.on("area").do(-> done())
        circle = safe_require "../test/circle.js", @policy.build()
        circle.area(1).should.be.approximately 3, 1

    it "should call external functions (2)", (done) =>
        beenHereBefore = false
        @policy.before("area").do(-> beenHereBefore = true)
               .after("area").do(-> done() if beenHereBefore)
        circle = safe_require "../test/circle.js", @policy.build()
        circle.area(1).should.be.approximately 3, 1

    it "should call external functions", (done) =>
        @policy.after("area").do(-> done())
        circle = safe_require "../test/circle.js", @policy.build()
        circle.area(1).should.be.approximately 3, 1

    it "should throw errors", =>
        @policy.after("area").do(-> throw new Error("this should throw"))
        circle = safe_require "../test/circle.js", @policy.build()
        (circle.area).should.throw()

    it "should sequence actions", (done) =>
        beenHereBefore = false
        @policy.on("area")
            .do(-> beenHereBefore = true)
            .do(-> done() if beenHereBefore)

        circle = safe_require "../test/circle.js", @policy.build()
        circle.area(1).should.be.approximately 3, 1

    it "should sequence rules", (done) =>
        beenHereBefore = false
        @policy
            .on("area").do(-> beenHereBefore = true)
            .on("area").do(-> done() if beenHereBefore)

        circle = safe_require "../test/circle.js", @policy.build()
        circle.area(1).should.be.approximately 3, 1
