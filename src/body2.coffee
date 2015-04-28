module.exports = (buffer, header, key, callback) ->
  
  
  if typeof(key) isnt 'string'
    key = Object.keys(header.variables)[key]
  
  