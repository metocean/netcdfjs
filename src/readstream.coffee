fs = require 'fs'

module.exports = (file) ->
  read = fs.createReadStream file
  requests = []
  drain = ->
    return if requests.length is 0
    request = requests[0]
    chunk = read.read request.bytes
    return if chunk is null
    requests.shift()
    request.cb new Uint8Array chunk
    drain()
  read.on 'readable', -> drain()
  close: -> read.destroy()
  read: (n, cb) ->
    requests.push bytes: n, cb: cb
    drain()
  on: (e, cb) -> read.on e, cb