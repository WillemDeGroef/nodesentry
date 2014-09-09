should = require 'should'
Membrane = require('../src/membrane')

describe 'Generic membrane', ->

    wetObj = {x: {y: 2}, z: new Buffer("hello"), a: [1,2,3,4]}
    interceptedGets = 0
    memHandler =
            onGet: (tgt, name, rcvr, drytgt, ret) ->
                interceptedGets++
                ret
    dryObj = new Membrane wetObj, memHandler

    it 'should allow access to all properties', ->
        dryObj.should.have.property "x"
        dryFoo = dryObj.x
        dryFoo.should.have.property "y"
        dryFoo.y.should.equal 2

    it 'should run the handler', ->
        dryFoo = dryObj.x
        #interceptedGets is updated via the memory handler
        interceptedGets.should.equal 9

    it 'should work on built-in libraries', ->
        os = require "os"
        os2 = new Membrane(os, memHandler)
        os2.should.have.properties Object.getOwnPropertyNames(os)

    it 'should work with buffers', ->
        dryObj.should.have.property "z"
        dryObj.z.toString().should.equal "hello"
        Buffer.isBuffer(dryObj.z).should.be.true
        (dryObj.z instanceof Buffer).should.be.true

    it 'should work with buffers (2)', ->
        dryObj.q = new Buffer("world")
        wetObj.should.have.property "q"
        wetObj.q.toString().should.equal "world"
        Buffer.isBuffer(wetObj.q).should.be.true
        (wetObj.q instanceof Buffer).should.be.true
