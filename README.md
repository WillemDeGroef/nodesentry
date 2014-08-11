# NodeSentry

Node.js is a popular JavaScript server-side frame-work with an efficient runtime for cloud-based event-driven architectures. Its strength is the presence of thousands of third party libraries which allow developers to quickly build and deploy applications.These very libraries are a source of security threats as a vulnerability in one library can (and in some cases did) compromise one’s entire server. 

In order to support the least-privilege integration of libraries we develop NodeSentry, the first security architecture for server-side JavaScript. Our policy enforcement infrastructure supports an easy deployment of web-hardening techniques and access control policies on interactions between libraries and their environment, including any dependent library

Read the extended abstract at https://lirias.kuleuven.be/bitstream/123456789/458467/1/jstools.pdf

## Installation Instructions

Install the module via npm: `npm install nodesentry`

Build status: [![Build Status](https://travis-ci.org/WillemDeGroef/nodesentry.svg?branch=master)](https://travis-ci.org/WillemDeGroef/nodesentry)

## Test Scenario

Run the tests with `npm test` and take a look at `test/st.test.coffee` for a real-life use case.

## Example

Enable all harmony features when running node: `node --harmony`

    require("nodesentry");
    var policyObj = {
        onGet: function (wTgt, name, wRec, dTgt, ret) {
            console.log("os." + name);
            return ret;
        }
    };
    var os = safe_require("os", policyObj);
    console.log(os.uptime());
    console.log(os.hostname());

The example loads the built-in `os` library and prints the name each time a member is called.


## License

This software is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for more information.
Copyright 2014 -- iMinds-DistriNet, KU Leuven
