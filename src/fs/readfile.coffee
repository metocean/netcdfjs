fs = require 'fs'
readbuffer = require './readbuffer'

module.exports = (file) ->
  buf = fs.readFileSync file, encoding: null
  ab = new ArrayBuffer buf.length
  view = new Uint8Array ab
  for i in [0...buf.length]
    view[i] = buf[i]
  readbuffer ab