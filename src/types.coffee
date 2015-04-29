arraysfill = require './arraysfill'
single = require './singleprimatives'

marker =
  byte: [0, 0, 0, 1]
  char: [0, 0, 0, 2]
  short: [0, 0, 0, 3]
  int: [0, 0, 0, 4]
  float: [0, 0, 0, 5]
  double: [0, 0, 0, 6]

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

module.exports = (data) ->
  many = arraysfill data
  types =
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
    singleReader: (type, fill) ->
      if !single[type]?
        throw new Error "A reader for #{type} not found"
      f = single[type]
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