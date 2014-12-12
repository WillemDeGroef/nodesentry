var Policy = require("nodesentry").Policy;

function invalidUrl (reqObj, url) { return url.indexOf("%2e") > -1 };

function errorPage () { return "/404.html" };

var policyObj = new Policy()

    .on("IncomingMessage.url")
        .return(errorPage).if(invalidUrl)

.build();

module.exports = policyObj;
