Lexer = require './lexer'
constants = require './constants'

class Header
  constructor: (data) ->
    @lex = new Lexer data
  
  header: =>
    version: @magic()
    records: @numrecs()
    dimensions: @dim_list()
    globalattributes: @att_list()
    attributes: @att_list()
    variables: @var_list()
  
  # 'C'  'D'  'F'  VERSION
  magic: =>
    return @error 'Not a valid NetCDF file' if @lex.string(3) isnt 'CDF'
    version = @lex.byte()
    unless version in [1, 2, 3]
      throw new Error "Unknown NetCDF format (version #{version})"
    description = 'Classic format' if version is 1
    description = '64 bit offset format' if version is 2
    number: version
    description: description
  
  numrecs: =>
    if @lex.match constants.streamingMarker
      @lex.forward constants.streamingMarker.length
      type: 'streaming'
    else
      numrecs = @lex.uint32()
      type: 'fixed'
      number: numrecs
  
  # ABSENT | NC_DIMENSION  nelems  [dim ...]
  dim_list: =>
    if @lex.match constants.zeroMarker
      @lex.forward constants.zeroMarker.length
      return null
    
    if not @lex.match constants.dimensionMarker
      throw new Error 'Dimension marker not found'
    @lex.forward constants.dimensionMarker.length
    
    [0...@lex.uint32()].map => @dim()
  
  dim: =>
    dim =
      name: @name()
      length: @lex.uint32() ? 0
    dim.length = null if dim.length is 0
    dim
  
  name: =>
    length = @lex.uint32()
    res = @lex.string length
    @lex.fill length
    res
  
  # ABSENT | NC_ATTRIBUTE  nelems  [attr ...]
  att_list: =>
    if @lex.match constants.zeroMarker
      @lex.forward constants.zeroMarker.length
      return null
    
    if not @lex.match constants.attributeMarker
      throw new Error 'Attribute marker not found'
    @lex.forward constants.attributeMarker.length
    
    res = {}
    for [0...@lex.uint32()]
      attr = @attr()
      res[attr.name] = attr.value
    res
  
  # name  nc_type  nelems  [values ...]
  attr: =>
    name: @name()
    value: @lex.reader(@lex.type()) @lex.uint32()
  
  # ABSENT | NC_VARIABLE   nelems  [var ...]
  var_list: =>
    if @lex.match constants.zeroMarker
      @lex.forward constants.zeroMarker.length
      return null
    
    if not @lex.match constants.variableMarker
      throw new Error 'Variable marker not found'
    @lex.forward constants.variableMarker.length
    
    res = {}
    for [0...@lex.uint32()]
      variable = @var()
      res[variable.name] = variable.value
    res
  
  # name  nelems  [dimid ...]  vatt_list  nc_type  vsize  begin
  var: =>
    name: @name()
    value:
      dimensions: [0...@lex.uint32()].map => @lex.uint32()
      attributes: @att_list()
      type: @lex.type()
      size: @lex.uint32()
      offset: @lex.uint32()

module.exports = (data) -> new Header(data).header()
