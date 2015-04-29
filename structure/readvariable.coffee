readdimension = require './readdimension'

module.exports = (header, buffer, variable, cb) ->
  if typeof(variable) is 'string'
    variable = header.variables[variable]
  
  buffer.go variable.offset
  buffer.read variable.size, (content) ->
    cb null, readdimension content, 0, variable