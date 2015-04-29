# Read a single variable that isn't part of the record dimension.

readdimension = require './readdimension'

# variable can be either the variable name or the variable object itself
module.exports = (header, buffer, variable, cb) ->
  if typeof(variable) is 'string'
    variable = header.variables[variable]
  
  buffer.go variable.offset
  buffer.read variable.size, (content) ->
    cb null, readdimension content, 0, variable