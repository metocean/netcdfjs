readbinary = require '../util/readbinary'
roundup = require '../util/roundup'

module.exports = (data) ->
  byte: (n, cb) ->
    data.read roundup(n, 4), (b) ->
      cb [0...n].map (i) -> b[i]
  char: (n, cb) ->
    data.read roundup(n, 4), (b) ->
      cb readbinary.string(b).substr 0, n
  short: (n, cb) ->
    data.read roundup(2 * n, 4), (b) ->
      res = readbinary.short b, 2 * i for i in [0...n]
      cb res
  int: (n, cb) ->
    data.read 4 * n, (b) ->
      res = readbinary.int b, 4 * i for i in [0...n]
      cb res
  float: (n, cb) ->
    data.read 4 * n, (b) ->
      res = readbinary.float b, 4 * i for i in [0...n]
      cb res
  double: (n, cb) ->
    data.read 8 * n, (b) ->
      res = readbinary.double b, 8 * i for i in [0...n]
      cb res