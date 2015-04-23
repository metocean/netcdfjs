TA = require 'typedarray'

module.exports = (buffer) ->
  index = 0
  length = buffer
  ends = []
  read: (n, cb) ->
    if index + n >= length
      e() for e in ends
      ends = []
      return
    index += n
    cb new TA.Uint8Array buffer, index - n, n
  on: (e, cb) ->
    ends.push cb if e is 'end'