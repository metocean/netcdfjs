Lexer = require './lexer'
util = require './util'

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
      return @error "I don't know how to read NetCDF version #{version}"
    description = 'Classic format' if version is 1
    description = '64 bit offset format' if version is 2
    number: version
    description: description
  
  numrecs: =>
    numrecs = @lex.bytes 4
    if util.test.isFFFFFFFF numrecs
      type: 'streaming'
    else
      numrecs = util.convert.uint32 numrecs
      type: 'fixed'
      number: numrecs
  
  # ABSENT | NC_DIMENSION  nelems  [dim ...]
  dim_list: =>
    id = @lex.bytes 4
    return null if util.test.isZero id
    if not util.test.isDimension id
      return @error 'Dimension identifier not found'
    num = @lex.uint32()
    [1..num].map => @dim()
  
  dim: =>
    dim =
      name: @name()
      length: @lex.uint32()
    dim.length = null if dim.length is 0
    dim
  
  name: =>
    length = @lex.uint32()
    res = @lex.string length
    @lex.fill length
    res
  
  # ABSENT | NC_ATTRIBUTE  nelems  [attr ...]
  att_list: =>
    id = @lex.bytes 4
    return null if util.test.isZero id
    if not util.test.isAttribute id
      return @error 'Attribute identifier not found'
    num = @lex.uint32()
    res = {}
    for [1..num]
      attr = @attr()
      res[attr.name] = attr.value
    res
  
  # name  nc_type  nelems  [values ...]
  attr: =>
    name = @name()
    converter = util.convert.converter @lex.bytes 4
    num = @lex.uint32()
    numbytes = num * converter.bytes
    value = converter.convert @lex.bytes numbytes
    @lex.fill numbytes
    name: name
    value: value
  
  # ABSENT | NC_VARIABLE   nelems  [var ...]
  var_list: =>
    id = @lex.bytes 4
    return null if util.test.isZero id
    if not util.test.isVariable id
      return @error 'Variable identifier not found'
    num = @lex.uint32()
    res = {}
    for [1..num]
      variable = @var()
      res[variable.name] = variable.value
    res
  
  # name  nelems  [dimid ...]  vatt_list  nc_type  vsize  begin
  var: =>
    name = @name()
    num = @lex.uint32()
    name: name
    value:
      dimensions: [1..num].map => @lex.uint32()
      attributes: @att_list()
      type: util.convert.type @lex.bytes 4
      size: @lex.uint32()
      offset: @lex.uint32()

module.exports = (data) -> new Header(data).header()
