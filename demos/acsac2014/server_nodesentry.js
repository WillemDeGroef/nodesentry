require("nodesentry");
var http = require("http");
var st = safe_require("../st", require("./policies.js"));

var cwd = process.cwd();
var handler = st(cwd);

var server = http.createServer(handler).listen(9999);
console.log('wget -S -O - "http://localhost:9999/%2e%2e/%2e%2e/%2e%2e/%2e%2e/%2e%2e/%2e%2e/%2e%2e/%2e/%2e/etc/passwd" 2>&1|less');
