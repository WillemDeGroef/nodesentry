should = require 'should'
ModuleLoader = require "../src/module"

describe "ModuleLoader", ->
    it "should load libraries", ->
        loader = new ModuleLoader "../test/circle.js", module.paths
        e = loader.load(require)
        e.should.have.properties ["PI", "area", "circumference", "test"]
        e.area(1).should.be.approximately 3, 1

    it "should allow custom `require` functions", (done) ->
        loader = new ModuleLoader "../test/circle.js", module.paths
        customRequire = ->
            done()
            require.apply this, arguments
        e = loader.load customRequire
        e.should.have.properties ["PI", "area", "circumference", "test"]
        e.area(1).should.be.approximately 3, 1
        e.test().should.be.above 0

    it "should wrap recursively", (done) ->
        loader = new ModuleLoader "../test/circle.js", module.paths
        customRequire = (libName) ->
            done() if libName == "os"
            require.apply this, arguments
        (loader.load customRequire).test().should.be.above 0
