// Generated by CoffeeScript 1.9.1
var readbinary, roundup;

readbinary = require('../util/readbinary');

roundup = require('../util/roundup');

module.exports = function(data) {
  return {
    byte: function(n, cb) {
      return data.read(roundup(n, 4), function(b) {
        var j, results;
        return cb((function() {
          results = [];
          for (var j = 0; 0 <= n ? j < n : j > n; 0 <= n ? j++ : j--){ results.push(j); }
          return results;
        }).apply(this).map(function(i) {
          return b[i];
        }));
      });
    },
    char: function(n, cb) {
      return data.read(roundup(n, 4), function(b) {
        return cb(readbinary.string(b).substr(0, n));
      });
    },
    short: function(n, cb) {
      return data.read(roundup(2 * n, 4), function(b) {
        var i, j, ref, res;
        for (i = j = 0, ref = n; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
          res = readbinary.short(b, 2 * i);
        }
        return cb(res);
      });
    },
    int: function(n, cb) {
      return data.read(4 * n, function(b) {
        var i, j, ref, res;
        for (i = j = 0, ref = n; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
          res = readbinary.int(b, 4 * i);
        }
        return cb(res);
      });
    },
    float: function(n, cb) {
      return data.read(4 * n, function(b) {
        var i, j, ref, res;
        for (i = j = 0, ref = n; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
          res = readbinary.float(b, 4 * i);
        }
        return cb(res);
      });
    },
    double: function(n, cb) {
      return data.read(8 * n, function(b) {
        var i, j, ref, res;
        for (i = j = 0, ref = n; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
          res = readbinary.double(b, 8 * i);
        }
        return cb(res);
      });
    }
  };
};