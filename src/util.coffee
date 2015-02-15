{ TextDecoder } = require 'text-encoding'
decoder = new TextDecoder 'utf-8'

test =
  is4Byte: (data, bytes) =>
    data[0] is bytes[0] and data[1] is bytes[1] and data[2] is bytes[2] and data[3] is bytes[3]
  
  isFFFFFFFF: (data) => test.is4Byte data, [255, 255, 255, 255]
  isZero: (data) => test.is4Byte data, [0, 0, 0, 0]
  isDimension: (data) =>  test.is4Byte data, [0, 0, 0, 10]
  isVariable: (data) => test.is4Byte data, [0, 0, 0, 11]
  isAttribute: (data) => test.is4Byte data, [0, 0, 0, 12]
  
  isByte: (data) => test.is4Byte data, [0, 0, 0, 1]
  isChar: (data) => test.is4Byte data, [0, 0, 0, 2]
  isShort: (data) =>  test.is4Byte data, [0, 0, 0, 3]
  isInt: (data) => test.is4Byte data, [0, 0, 0, 4]
  isFloat: (data) => test.is4Byte data, [0, 0, 0, 5]
  isDouble: (data) => test.is4Byte data, [0, 0, 0, 6]

convert =
  uint64: (data) =>
    # TODO: find out the best way to handle 64 bit ints in javascript
    #data[0] << 56 | data[1] << 48 | data[2] << 40 | data[3] << 32 |
    data[4] << 24 | data[5] << 16 | data[6] << 8 | data[7]
  uint32: (data) =>
    data[0] << 24 | data[1] << 16 | data[2] << 8 | data[3]
  uint16: (data) => data[0] << 8 | data[1]
  string: (data) => decoder.decode data
  bytes: (data) =>
    # TODO: convert to numeric array
    data
  shorts: (data) => data
  ints: (data) => data
  floats: (data) => data
  doubles: (data) => data
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