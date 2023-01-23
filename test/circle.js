var PI = Math.PI;
module.exports.PI = PI;
module.exports.PI2 = new Number(PI);
module.exports.numbers = {PI: Math.PI, zero: 0};

module.exports.area = function (r) {
      return PI * r * r;
};

module.exports.circumference = function (r) {
      return 2 * PI * r;
};

module.exports.arr = ["a", "b"];

module.exports.test = function () {
    var os = require("os");
    return os.uptime();
};

module.exports.handle_buffer = function (b) {
    var v = b instanceof Buffer;
    if (v == false)
        return "incoming data was not an instance of Buffer";
    if (Buffer.isBuffer(b))
        return b.toString()
    else
        return "incoming data was not a buffer";
};

module.exports.get_buffer = function () {
    return new Buffer("hello");
};
