should = require 'should'
require "../src"
Policy = require "../src/policy"

describe "Policy", =>
    @policy = null

    beforeEach =>
        @policy = new Policy()

    it "should return a default policy", =>
        p = @policy.build()
        p.wrapWithMembrane("bleh").should.be.false
        p.onGet({}, "", {}, {}, 1234).should.equal 1234

    it "should modify return values", =>
        @policy.on("PI").return((origPI) -> 3*origPI)
        circle = require "./circle.js", @policy.build()
        circle.PI.should.approximately 3, 1

    it "should modify return values of functions", =>
        @policy.after("circle.area").return((r) -> 2*r)
        circle = safe_require "./circle.js", @policy.build()
        circle.area(1).should.approximately 6, 1

    it "should modify return values before function calls", =>
        @policy.before("circle.area").return((origRes) -> ((r) -> 2*origRes(r)))
        circle = safe_require "./circle.js", @policy.build()
        circle.area(1).should.approximately 6, 1

    it "should call external functions before the actual call", (done) =>
        @policy.before("circle.area").do(-> done())
        circle = safe_require "./circle.js", @policy.build()
        circle.area(1).should.be.approximately 3, 1

    it "should call external functions after the actual call", (done) =>
        @policy.after("circle.area").do(-> done())
        circle = safe_require "./circle.js", @policy.build()
        circle.area(1).should.be.approximately 3, 1

    it "should call external functions", (done) =>
        beenHereBefore = false
        @policy.before("circle.area").do(-> beenHereBefore = true)
               .after("circle.area").do(-> done() if beenHereBefore)
        circle = safe_require "./circle.js", @policy.build()
        circle.area(1).should.be.approximately 3, 1

    it "should throw errors", =>
        @policy.before("circle.area").do(-> throw new Error)
        circle = safe_require "./circle.js", @policy.build()
        (-> circle.area(1)).should.throw()

    it "should sequence actions", (done) =>
        beenHereBefore = false
        @policy.after("circle.area")
            .do(-> beenHereBefore = true)
            .do(-> done() if beenHereBefore)

        circle = safe_require "./circle.js", @policy.build()
        circle.area(1).should.be.approximately 3, 1

    it "should sequence rules", (done) =>
        beenHereBefore = false
        @policy
            .before("circle.area").do(-> beenHereBefore = true)
            .after("circle.area").do(-> done() if beenHereBefore)

        circle = safe_require "./circle.js", @policy.build()
        circle.area(1).should.be.approximately 3, 1
