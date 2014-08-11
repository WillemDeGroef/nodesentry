should = require "should"
Policy = require "../src/policy"
require "../src"

describe "Upper-bound Policies", () =>
    @server = null
    max = 32000
    min = 1025
    @port = Math.floor(Math.random() * (max - min) + min)

    afterEach =>
        try @server.close()

    it "can add extra HTTP response headers", (done) =>
        policyObj = (new Policy()).build()
        policyObj.onGet = (wTgt, name, wRec, dTgt, ret) ->
            funcCall = "#{dTgt.constructor.name.toString()}.#{name}"
            # add it right before the headers get 
            if funcCall == "ServerResponse.writeHead"
                dTgt.setHeader "X-NodeSentry", "What Else?!"
            return ret

        http = safe_require "http", policyObj
        @server = http.createServer((req, res) ->
            res.writeHead 200, {'Content-Type': 'text/plain'}
            res.end 'Hello World\n'
        ).listen(@port)
        http.get "http://localhost:#{@port}/", (res) ->
            res.statusCode.should.equal 200
            res.headers.should.have.property 'x-nodesentry'
            done()


