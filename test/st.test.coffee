# !! be careful as this runs a vulnerable version st !!
http = require "http"
should = require "should"
Policy = require("../src").Policy

describe "`st@0.2.4`", () =>
    @server = null
    max = 32000
    min = 1025

    validUrl = (url) -> url.indexOf("%2e") > -1 or url.indexOf("..") > -1

    @po = new Policy()
            .on "IncomingMessage.url"
                .return -> "/redirect_to_404_page"
                .if (incomingMessage, url) -> validUrl url
                .build()

    beforeEach =>
        @port = Math.floor(Math.random() * (max - min) + min)

    afterEach =>
        try @server.close()

    it "should work", (done) =>
        st = require "../demos/st"
        @server = http.createServer(st(process.cwd())).listen(@port)
        http.get "http://localhost:#{@port}/package.json", (res) ->
            res.statusCode.should.equal 200
            done()

    it "should work on /", (done) =>
        st = require "../demos/st"
        @server = http.createServer(st(process.cwd())).listen(@port)
        http.get "http://localhost:#{@port}/", (res) ->
            res.statusCode.should.equal 200
            done()


    it "should work for non-existant files", (done) =>
        st = require "../demos/st"
        @server = http.createServer(st(process.cwd())).listen(@port)
        http.get "http://localhost:#{@port}/package.jso", (res) ->
            res.statusCode.should.equal 404
            done()

    it "should be vulnerable", (done) =>
        st = require "../demos/st"
        @server = http.createServer(st(process.cwd())).listen(@port)
        http.get "http://localhost:#{@port}/../package.json", (res) ->
            res.statusCode.should.equal 200
            done()

    it "should be still functional under NodeSentry", (done) =>
        st = safe_require "../demos/st", @po
        @server = http.createServer(st(process.cwd())).listen(@port)
        http.get "http://localhost:#{@port}/package.json", (res) ->
            res.statusCode.should.equal 200
            done()

    it "should be still functional under NodeSentry (2)", (done) =>
        st = safe_require "../demos/st", @po
        @server = http.createServer(st(process.cwd())).listen(@port)
        http.get "http://localhost:#{@port}/package.jso", (res) ->
            res.statusCode.should.equal 404
            done()

    it "should be still functional under NodeSentry (3)", (done) =>
        st = safe_require "../demos/st", @po
        @server = http.createServer(st(process.cwd())).listen(@port)
        http.get "http://localhost:#{@port}/", (res) ->
            res.statusCode.should.equal 200
            res.on "data", (data) ->
                do done if data.toString().indexOf("package.json") > -1

    it "shouldn't be vulnerable anymore", (done) =>
        st = safe_require "../demos/st", @po
        @server = http.createServer(st(process.cwd())).listen(@port)
        http.get "http://localhost:#{@port}/../package.json", (res) ->
            res.statusCode.should.equal 404
            res.on "data", (data) ->
                console.log data.toString()
            done()
