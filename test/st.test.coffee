# !! be careful as this runs a vulnerable version st !!
http = require "http"
should = require "should"
Policy = require "../src/policy"
require "../src"

describe "`st@0.2.4`", () =>
    @server = null
    max = 32000
    min = 1025
    @po = new Policy()
             .on("IncomingMessage.url")
                .return((origUrl) -> "/redirect_to_404_page")
                .if((dtgt, url) ->
                    url.indexOf("%2e") > -1 or url.indexOf("..") > -1)
            .build()

    beforeEach =>
        @port = Math.floor(Math.random() * (max - min) + min)

    afterEach =>
        try @server.close()

    it "should work", (done) =>
        st = require "../demos/st"
        @server = http.createServer(st(process.cwd())).listen(@port)
        http.get "http://localhost:#{@port}/", (res) ->
            res.statusCode.should.equal 200
            done()

    it "should be vulnerable", (done) =>
        st = require "../demos/st"
        @server = http.createServer(st(process.cwd())).listen(@port)
        http.get "http://localhost:#{@port}/../package.json", (res) ->
            res.statusCode.should.equal 200
            done()

    it "should be still functional under NodeSentry", (done) =>
        st = safe_require "../demos/st", {}
        @server = http.createServer(st(process.cwd())).listen(@port)
        http.get "http://localhost:#{@port}/", (res) ->
            res.statusCode.should.equal 200
            done()

    it "should be secure for malicious requests", (done) =>
        st = safe_require "../demos/st", @po
        @server = http.createServer(st(process.cwd())).listen(@port)
        http.get "http://localhost:#{@port}/../package.json", (res) ->
            res.statusCode.should.equal 404
            done()

    it "should be secure for non-malicious requests", (done) =>
        st = safe_require "../demos/st", @po
        @server = http.createServer(st(process.cwd())).listen(@port)
        http.get "http://localhost:#{@port}/", (res) ->
            res.statusCode.should.equal 200
            done()


