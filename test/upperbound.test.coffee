should = require "should"
Policy = require("../src").Policy

describe "Upper-bound Policies", () =>
    @server = null
    max = 32000
    min = 1025
    @port = Math.floor(Math.random() * (max - min) + min)

    afterEach =>
        try @server.close()

    it "can add extra HTTP response headers", (done) =>
        p = new Policy()
            .before("ServerResponse.writeHead")
                .do((response) ->
                    response.setHeader "X-NodeSentry", "What Else?!")
            .build()

        http = safe_require "http", p
        @server = http.createServer((req, res) ->
            res.writeHead 200, {'Content-Type': 'text/plain'}
            res.end 'Hello World\n'
        ).listen(@port)

        http.get "http://localhost:#{@port}/", (res) ->
            res.statusCode.should.equal 200
            res.headers.should.have.property 'x-nodesentry'
            done()


