should = require "should"
Policy = require("../src").Policy

describe "Upper-bound Policies", () =>
    @server = null
    max = 32000
    min = 1025
    @port = Math.floor(Math.random() * (max - min) + min)

    afterEach =>
        try @server.close()

    startHTTPServer = (http, f) =>
        @server = http.createServer(f).listen(@port)

    it "can add extra HTTP response headers", (done) =>
        p = new Policy()
            .on("ServerResponse.writeHead")
                .do((response) -> response.setHeader "X-NodeSentry", "What Else?!")

        msg = "Hello World\n"
        http = safe_require "http", p.build()
        startHTTPServer(http, (req, res) ->
            res.writeHead 200, {'Content-Type': 'text/plain'}
            res.end msg
        )

        http.get "http://localhost:#{@port}/", (res) ->
            res.statusCode.should.equal 200
            res.headers.should.have.property 'x-nodesentry'
            res.on "data", (data) ->
                data.toString().should.equal msg
                done()

    it.skip "can forbid access to any library", (done) =>
        p = new Policy()
            .disable("fs")
            .build()

        http = safe_require "http", p
        @server = http.createServer((req, res) ->
            fs = require "fs"
            res.writeHead 200, {'Content-Type': 'text/plain'}
            res.end "empty"
            res.end fs.readFileSync("/tmp/does_not_exist_but_doesnt_matter")
        ).listen(@port)

        http.get "http://localhost:#{@port}/", (res) ->
            res.statusCode.should.equal 200
            res.on "data", (data) ->
                data.toString().should.equal ""
                done()
