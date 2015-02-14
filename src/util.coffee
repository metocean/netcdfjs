{ TextDecoder } = require 'text-encoding'
decoder = new TextDecoder 'utf-8'

test =
  isFFFFFFFF: (data) =>
    data[0] is 255 and data[1] is 255 and data[2] is 255 and data[3] is 255
  isZero: (data) =>
    data[0] is 0 and data[1] is 0 and data[2] is 0 and data[3] is 0
  isDimension: (data) =>
    data[0] is 0 and data[1] is 0 and data[2] is 0 and data[3] is 10
  isVariable: (data) =>
    data[0] is 0 and data[1] is 0 and data[2] is 0 and data[3] is 11
  isAttribute: (data) =>
    data[0] is 0 and data[1] is 0 and data[2] is 0 and data[3] is 12
  
  isByte: (data) =>
    data[0] is 0 and data[1] is 0 and data[2] is 0 and data[3] is 1
  isChar: (data) =>
    data[0] is 0 and data[1] is 0 and data[2] is 0 and data[3] is 2
  isShort: (data) =>
    data[0] is 0 and data[1] is 0 and data[2] is 0 and data[3] is 3
  isInt: (data) =>
    data[0] is 0 and data[1] is 0 and data[2] is 0 and data[3] is 4
  isFloat: (data) =>
    data[0] is 0 and data[1] is 0 and data[2] is 0 and data[3] is 5
  isDouble: (data) =>
    data[0] is 0 and data[1] is 0 and data[2] is 0 and data[3] is 6

convert =
  uint64: (data) =>
    #data[0] << 56 | data[1] << 48 | data[2] << 40 | data[3] << 32 |
    data[4] << 24 | data[5] << 16 | data[6] << 8 | data[7]
  uint32: (data) =>
    data[0] << 24 | data[1] << 16 | data[2] << 8 | data[3]
  uint16: (data) =>
    data[0] << 8 | data[1]
  string: (data) =>
    decoder.decode data
  bytes: (data) =>
    data
  shorts: (data) =>
  ints: (data) =>
  floats: (data) =>
  doubles: (data) =>
  type: (data) =>
    return 'byte' if test.isByte data
    return 'char' if test.isChar data
    return 'short' if test.isShort data
    return 'int' if test.isInt data
    return 'float' if test.isFloat data
    return 'double' if test.isDouble data
    null
  converter: (data) =>
    converter =
      byte: bytes: 1, convert: convert.bytes
      char: bytes: 1, convert: convert.string
      short: bytes: 2, convert: convert.shorts
      int: bytes: 4, convert: convert.ints
      float: bytes: 4, convert: convert.floats
      double: bytes: 4, convert: convert.doubles
    converter[convert.type data]

module.exports =
  decoder: decoder
  test: test
  convert: convert