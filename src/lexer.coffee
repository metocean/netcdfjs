util = require './util'

module.exports = class Lexer
  constructor: (data) ->
    @_data = data
    @_index = 0
    @_length = data.length
  
  hasMore: => @_index < @_length
  next: => @_index++
  byte: =>
    result = @_data[@_index]
    @next()
    result
  char: => String.fromCharCode @byte()
  hex: => @byte().toString 16
  
  bytes: (n) =>
    return null if @_index + n > @_length or n is 0
    result = @_data.subarray @_index, @_index + n
    @_index += n
    result
  fill: (n) =>
    b = Math.ceil(n / 4) * 4 - n
    return if b is 0
    @bytes b
  string: (n) =>
    result = @bytes n
    return null if result is null
    util.decoder.decode result
  uint16: =>
    util.convert.uint16 @bytes 2
  uint32: =>
    util.convert.uint32 @bytes 4
  uint64: =>
    util.convert.uint64 @bytes 8
  print: =>
    index = @_index
    a = =>
      res = @_data[index].toString 16
      index++
      return "0#{res}" if res.length is 1
      res
    b = -> "#{a()}#{a()}#{a()}#{a()}"
    c = ->
      console.log()
      console.log "#{b()} #{b()} #{b()} #{b()}"
      console.log "#{b()} #{b()} #{b()} #{b()}"
      console.log "#{b()} #{b()} #{b()} #{b()}"
      console.log "#{b()} #{b()} #{b()} #{b()}"
    c() for i in [0..3]