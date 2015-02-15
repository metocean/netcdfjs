Lexer = require './lexer'
util = require './util'

class Body
  constructor: (data) ->
    @lex = new Lexer data
  
  body: (header, index) =>
    key = Object.keys(header.variables)[index]
    variable = header.variables[key]
    dimensions = variable.dimensions.map (i) -> header.dimensions[i]
    
    key: key
    variable: variable
    dimensions: dimensions

module.exports = (data, header, index) ->
  new Body(data).body header, index