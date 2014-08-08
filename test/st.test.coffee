# !! be careful as this runs a vulnerable version st !!
http = require "http"
should = require "should"
Policy = require "../src/policy"
require "../src"

describe "`st@0.2.4`", () =>
    @server = null
    max = 32000
    min = 1025
    @port = Math.floor(Math.random() * (max - min) + min)

    afterEach =>
        try @server.close()

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

    it "should be secure under NodeSentry", (done) =>
        policyObj = (new Policy()).build()
        policyObj.onGet = (wTgt, name, wRec, dTgt, ret) ->
            funcCall = "#{dTgt.constructor.name.toString()}.#{name}"
            if funcCall == "IncomingMessage.url" and (ret.indexOf("%2e") > -1 or ret.indexOf("..") > -1)
                return "/redirect_to_404_page"
            ret

        st = safe_require "../demos/st", policyObj
        @server = http.createServer(st(process.cwd())).listen(@port)
        http.get "http://localhost:#{@port}/../package.json", (res) ->
            res.statusCode.should.equal 404
            done()
