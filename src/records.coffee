module.exports = (header, buffer, cb) ->
  if header.records.number is 0
    return cb new Error 'No records'
  
  type = require('./types') buffer
  
  readslab = (result, position, content) ->
    for name, offset of header.records.offsets
      variable = header.variables[name]
      fill = variable.attributes._FillValue or type.fill variable.type
      reader = type.singleReader variable.type, fill
      result[name].push reader content, position + offset
  
  buffer.go header.records.offset
  buffer.read header.records.size * header.records.number, (content) ->
    result = {}
    for key, _ of header.records.offsets
      result[key] = []
    for i in [0...header.records.number]
      readslab result, i * header.records.size, content
    cb null, result