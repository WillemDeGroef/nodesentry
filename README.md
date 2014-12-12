# NodeSentry

Node.js is a popular JavaScript server-side frame-work with an efficient runtime for cloud-based event-driven architectures. Its strength is the presence of thousands of third party libraries which allow developers to quickly build and deploy applications.These very libraries are a source of security threats as a vulnerability in one library can (and in some cases did) compromise one’s entire server. 

In order to support the least-privilege integration of libraries we develop NodeSentry, the first security architecture for server-side JavaScript. Our policy enforcement infrastructure supports an easy deployment of web-hardening techniques and access control policies on interactions between libraries and their environment, including any dependent library

This work has been presented at the 2014 Annual Computer Security Applications Conference.

---

**NodeSentry: Least-privilege Library Integration for Server-side JavaScript**. Willem De Groef, Fabio Massacci and Frank Piessens.
In _Proceedings of the 30th Annual Computer Security Applications Conference (ACSAC)_, pages 446-455, 2014.
[PDF](static/nodesentry.pdf) | [BibTeX](static/nodesentry.bib) | [presentation](static/presentation.pdf)

---

## Installation Instructions

Install this module directly: `npm install nodesentry`

## Status

* Build status: [![Build Status](https://travis-ci.org/WillemDeGroef/nodesentry.svg?branch=master)](https://travis-ci.org/WillemDeGroef/nodesentry)
* Dependencies: [![Dependencies](https://david-dm.org/willemdegroef/nodesentry.svg)](https://david-dm.org/willemdegroef/nodesentry)
* NPM Module: [![NPM version](https://badge.fury.io/js/nodesentry.svg)](http://badge.fury.io/js/nodesentry)

## Examples

Two examples showcase the real-life use case of the library.

### Adding custom HTTP headers

This example shows how you can add a custom HTTP header to any outgoing HTTP response of your HTTP server.
Please note that NodeSentry requires you to enable all harmony features of V8/Node.js when running node (use `node --harmony`).

```javascript
/* Enable NodeSentry */
var Policy = require("nodesentry").Policy;

/* This policy says that before a call to `ServerResponse.writeHead()` is
 * actually invoked, a custom header gets added to the response object.
 * More information on the Node.js API for HTTP server interactions on
 * http://nodejs.org/api/http.html */
var policy = new Policy()
    .before("ServerResponse.writeHead")
        .do(function(response) {
            return response.setHeader("X-NodeSentry", "What Else?!");
}).build() // build the actual policy object

/* Use `safe_require` to enforce generated policy */
var http = safe_require("http", policy);
//var http = require("http");

/* Pre-existing/unmodified application code */
var port = 12345;
var server = http.createServer(function(req, res) {
    res.writeHead(200, {'Content-Type': 'text/plain'});
    return res.end('Hello World\n');
}).listen(port);
```

This example is also used in the file `test/upperbound.test.coffee`, as part of our test suite.

## License

This software is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for more information.

_Copyright 2014 -- iMinds-DistriNet, KU Leuven_
