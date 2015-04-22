Lexer = require './lexer'

module.exports = class Body
  constructor: (data) ->
    @lex = new Lexer data
  
  body: (header, index) =>
    key = Object.keys(header.variables)[index]
    variable = header.variables[key]
    dimensions = variable.dimensions.map (i) -> header.dimensions[i]
    # presuming non-streaming
    for dim in dimensions
      dim.length = header.records.number if dim.length is null
    
    type = variable.type
    fill = variable.attributes._FillValue or @lex.fillForType type
    reader = @lex.readerForType type, fill
    
    @lex.go variable.offset
    
    key: key
    variable: variable
    dimensions: dimensions
    data: @slab dimensions, 0, reader
  
  slab: (dimensions, index, read) =>
    return read 1 if dimensions.length is 0
    
    if index is dimensions.length - 1
      return read dimensions[index].length
    
    dim = dimensions[index]
    for [0...dim.length]
      @slab dimensions, index + 1, read