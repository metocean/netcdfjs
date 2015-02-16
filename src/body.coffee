Lexer = require './lexer'

class Body
  constructor: (data) ->
    @lex = new Lexer data
  
  body: (header, index) =>
    key = Object.keys(header.variables)[index]
    variable = header.variables[key]
    dimensions = variable.dimensions.map (i) -> header.dimensions[i]
    # presuming non-streaming
    for dim in dimensions
      dim.length = header.records.number if dim.length is null
    
    @lex.go variable.offset
    #data = @slab dimensions, 0, util.convert.converterForType variable.type
    
    key: key
    variable: variable
    dimensions: dimensions
    #data: data
  
  slab: (dimensions, index, convert) =>
    return @lex.byte() if dimensions.length <= index
    
    dim = dimensions[index]
    for [0...dim.length]
      @slab dimensions, index + 1

module.exports = (data, header, index) ->
  new Body(data).body header, index