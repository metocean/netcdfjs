# Can only be used for reading header.
# Closes the stream once the header is read.

fs = require 'fs'

module.exports = (file) ->
  read = fs.createReadStream file
  requests = []
  drain = ->
    return if requests.length is 0
    request = requests[0]
    chunk = read.read request.bytes
    if chunk is null
      #console.log "r#{requests.length}: empty"
      return
    # console.log chunk
    requests.shift()
    if request.cb?
      request.cb new Uint8Array chunk
    # else
    #   console.log "r#{requests.length}: no callback"
    drain()
  read.on 'readable', ->
    # console.log "r#{requests.length}: readable"
    drain()
  close: -> read.destroy()
  read: (n, cb) ->
    requests.push bytes: n, cb: cb
    drain()
  on: (e, cb) -> read.on e, cb