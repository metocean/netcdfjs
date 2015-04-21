decoder = new require('text-encoding').TextDecoder 'utf-8'
constants = require './constants'

match = (data, index, bytes) ->
  return no if index + bytes.length > data.length
  for i in [0...bytes.length]
    return no if bytes[i] isnt data[index + i]
  yes

module.exports = class Lexer
  constructor: (data) ->
    @d = data
    @i = 0
    @n = data.length
  
  go: (i) => @i = i
  hasMore: => @i < @n
  next: => @i++
  forward: (n) => @i += n
  backward: (n) => @i -= n
  fill: (n) =>
    b = Math.ceil(n/4) * 4 - n
    return if b is 0
    @i += b
  match: (bytes) => match @d, @i, bytes
  print: (n) =>
    index = @i
    a = =>
      res = @d[index].toString 16
      index++
      return "0#{res}" if res.length is 1
      res
    b = -> "#{a()}#{a()}"
    c = ->
      console.log()
      console.log "#{b()} #{b()} #{b()} #{b()} #{b()} #{b()} #{b()} #{b()}"
    c() for i in [1..n]
  
  byte: =>
    @next()
    @d[@i-1]
  char: => String.fromCharCode @byte()
  hex: => @byte().toString 16
  read: (n) =>
    return null if @i + n > @n or n is 0
    @i += n
    @d.subarray @i-n, @i
  
  string: (n) => decoder.decode @read n
  uint8: =>
    @forward 1
    @d[@i-1]
  uint16: =>
    @forward 2
    @d[@i-2] << 8 | @d[@i-1]
  uint32: =>
    @forward 4
    @d[@i-4] << 24 | @d[@i-3] << 16 | @d[@i-2] << 8 | @d[@i-1]
  uint64: =>
    # TODO: find out the best way to handle 64 bit ints in javascript
    @forward 8
    @d[@i-4] << 24 | @d[@i-3] << 16 | @d[@i-2] << 8 | @d[@i-1]
  float: =>
    bytes = @uint32()
    sign = (bytes & 0x80000000) ? -1 : 1
    exponent = ((bytes >> 23) & 0xFF) - 127
    significand = (bytes & ~(-1 << 23))

    if exponent is 128
      if significand
        return sign * Number.NaN
      else
        return sign * Number.POSITIVE_INFINITY

    if exponent is -127
      return sign * 0.0 if significand is 0
      exponent = -126
      significand /= (1 << 22)
    else
      significand = (significand | (1 << 23)) / (1 << 23)
    
    sign * significand * Math.pow 2, exponent
  double: =>
    @forward 8
    0
    #throw new Error 'Not implemented'
  type: =>
    @forward 4
    rmatch = (bytes) => match @d, @i-4, bytes
    return 'byte' if rmatch constants.byteMarker
    return 'char' if rmatch constants.charMarker
    return 'short' if rmatch constants.shortMarker
    return 'int' if rmatch constants.intMarker
    return 'float' if rmatch constants.floatMarker
    return 'double' if rmatch constants.doubleMarker
    
    @backward 4
    @print 1
    throw new Error 'Type not found'
  
  chars: (n) =>
    result = @string n
    @fill n
    result
  bytes: (n) =>
    result = [0...n].map => @byte()
    @fill n
    result
  shorts: (n) =>
    result = [0...n].map => @uint16()
    @fill n * 2
    result
  ints: (n) => [0...n].map => @uint32()
  floats: (n) => [0...n].map => @float()
  doubles: (n) => [0...n].map => @double()
  reader: (type) =>
    throw new Error "A reader for #{type} not found" if !@["#{type}s"]?
    @["#{type}s"]