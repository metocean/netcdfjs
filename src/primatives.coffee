binary = require './binary'

module.exports = (data) ->
  primatives =
    byte: (cb) ->
      data.read 1, (b) ->
        cb binary.readByte b
    char: (cb) ->
      data.read 1, (b) ->
        cb binary.readChar b
    short: (cb) ->
      data.read 2, (b) ->
        cb binary.readShort b
    int: (cb) ->
      data.read 4, (b) ->
        cb binary.readInt b
    bigint: (cb) ->
      data.read 8, (b) ->
        cb binary.readBigInt b
    float: (cb) ->
      data.read 4, (b) ->
        cb binary.readFloat b
    double: (cb) ->
      data.read 8, (b) ->
        cb binary.readDouble b