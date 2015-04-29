# Read a type marker from a stream.
# Generate an array reader from a type literal.
# Used to read attributes.

readarrayfill = require './readarrayfill'

marker =
  byte: [0, 0, 0, 1]
  char: [0, 0, 0, 2]
  short: [0, 0, 0, 3]
  int: [0, 0, 0, 4]
  float: [0, 0, 0, 5]
  double: [0, 0, 0, 6]

module.exports = (data) ->
  many = readarrayfill data
  type: (cb) ->
    data.read 4, (b) ->
      match = (marker) ->
        for i in [0...marker.length]
          return no if marker[i] isnt b[i]
        yes
      for k, m of marker
        return cb k if match m
      throw new Error 'Type not found'
  reader: (type, fill) ->
    if !many[type]?
      throw new Error "A reader for #{type} not found"
    f = many[type]
    return f if !fill? or type is 'char'
    (n, cb) ->
      f n, (b) ->
        b.map (v) ->
          return null if v is fill
          v