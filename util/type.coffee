readbinary = require './readbinary'

fill =
  byte: -127
  char: 0
  short: -32767
  int: -2147483647
  float: 9.969209968386869e+36
  double: 9.969209968386869e+36

size =
  byte: 1
  char: 1
  short: 2
  int: 4
  float: 4
  double: 8

module.exports =
  reader: (type, fill) ->
    if !readbinary[type]?
      throw new Error "A reader for #{type} not found"
    f = readbinary[type]
    return f if !fill? or type is 'char'
    (b, i) ->
      result = f b, i
      return null if result is fill
      result
  fill: (type) ->
    return fill[type] if fill[type]?
    throw new Error "No fill found for #{type}"
  size: (type) ->
    return size[type] if size[type]?
    throw new Error "No size found for #{type}"