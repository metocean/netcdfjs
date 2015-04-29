readbinary = require '../util/readbinary'

module.exports = (data) ->
  primatives =
    byte: (cb) ->
      data.read 1, (b) ->
        cb readbinary.byte b
    char: (cb) ->
      data.read 1, (b) ->
        cb readbinary.char b
    short: (cb) ->
      data.read 2, (b) ->
        cb readbinary.short b
    int: (cb) ->
      data.read 4, (b) ->
        cb readbinary.int b
    bigint: (cb) ->
      data.read 8, (b) ->
        cb readbinary.bigint b
    float: (cb) ->
      data.read 4, (b) ->
        cb readbinary.float b
    double: (cb) ->
      data.read 8, (b) ->
        cb readbinary.double b