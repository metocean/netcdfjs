readdimension = require './dimension'

module.exports = (header, buffer, cb) ->
  if header.records.number is 0
    return cb new Error 'No records'
  
  readslab = (result, position, content) ->
    for name, offset of header.records.offsets
      result[name].push readdimension content, position + offset, header.variables[name]
  
  buffer.go header.records.offset
  buffer.read header.records.size * header.records.number, (content) ->
    result = {}
    for key, _ of header.records.offsets
      result[key] = []
    for i in [0...header.records.number]
      readslab result, i * header.records.size, content
    cb null, result