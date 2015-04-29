# Read random parts of the file.
# Use this for record and variable reading off a file.
# Can be used for reading header however readstream is recommended.

fs = require 'fs'

module.exports = (file) ->
  fd = fs.openSync file, 'r'
  index = 0
  ends = []
  close: -> fs.closeSync fd
  read: (n, cb) ->
    index += n
    buf = new Buffer n
    fs.read fd, buf, 0, n, index - n, (err, bytesRead, buf) ->
      if err?
        e() for e in ends
        ends = []
        return
      buf = new Uint8Array buf
      cb buf
  go: (i) -> index = i
  on: (e, cb) ->
    ends.push cb if e is 'end'