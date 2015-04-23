Lexer = require './lexer'
constants = require './constants'

roundup = (num, multiple) ->
  return num if multiple is 0
  remainder = num % multiple
  return num if remainder is 0
  num + multiple - remainder

class Header
  constructor: (data) ->
    @lex = new Lexer data
  
  header: =>
    @precompute
      version: @magic()
      records: @numrecs()
      dimensions: @dim_list()
      attributes: @gatt_list()
      variables: @var_list()
  
  precompute: (header) =>
    for dim in header.dimensions
      if dim.length is null
        header.records.dimension = dim.index
        break
    
    @precompute_size v, header for _, v of header.variables
    
    header.hassinglerecord = false
    for _, v of header.variables
      if v.isrecord
        if header.hassinglerecord
          header.hassinglerecord = no
          break
        header.hassinglerecord = yes
    
    # Note on padding: In the special case when there is only one record variable and it is of type character, byte, or short, no padding is used between record slabs, so records after the first record do not necessarily start on four-byte boundaries.
    unless header.hassinglerecord
      for _, v of header.variables
        v.size = roundup v.size, 4
    
    header.recordsize = 0
    for _, v of header.variables
      continue unless v.isrecord
      header.recordsize += v.size
    
    header
  
  # Note on vsize: This number is the product of the dimension lengths (omitting the record dimension) and the number of bytes per value (determined from the type), increased to the next multiple of 4, for each variable. If a record variable, this is the amount of space per record (except that, for backward compatibility, it always includes padding to the next multiple of 4 bytes, even in the exceptional case noted below under "Note on padding"). The netCDF "record size" is calculated as the sum of the vsize's of all the record variables.
  precompute_size: (variable, header) =>
    indexes = variable.dimensions
    variable.dimensions =
        indexes: indexes
        sizes: []
        products: []
    
    return if indexes.length is 0
    
    product = 1
    products = [indexes.length-1..0].map (i) ->
      index = indexes[i]
      product *= header.dimensions[index].length
      product
    products = products.reverse()
    variable.dimensions.products = products
    
    sizes = products.map (p) -> p * variable.size
    variable.dimensions.sizes = products.map (p) =>
      p * @lex.sizeForType variable.type
    
    variable.isrecord = header.dimensions[indexes[0]].length is null
    
    size = @lex.sizeForType variable.type
    if variable.dimensions.indexes.length < 2
      return variable.size = size
    size = if variable.isrecord
        variable.dimensions.sizes[1]
      else
        variable.dimensions.sizes[0]
    variable.size = size
  
  # 'C'  'D'  'F'  VERSION
  magic: =>
    magicstring = @lex.string(3)
    throw new Error 'Not a valid NetCDF file ' + magicstring if magicstring isnt 'CDF'
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
      console.log 'no dimensions'
      @lex.forward 8
      return {}
    
    if not @lex.match constants.dimensionMarker
      throw new Error 'Dimension marker not found'
    @lex.forward constants.dimensionMarker.length
    
    count = @lex.uint32()
    if count is 0 and @lex.uint32() isnt constants.zeroMarker
      throw new Error 'No dimensions and no absent marker present'
    [0...count].map (index) =>
      res = @dim()
      res.index = index
      res
  
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
  
  gatt_list: => @att_list()
  vatt_list: => @att_list()
  
  # ABSENT | NC_ATTRIBUTE  nelems  [attr ...]
  att_list: =>
    if @lex.match constants.zeroMarker
      @lex.forward 8
      return {}
    
    if not @lex.match constants.attributeMarker
      throw new Error 'Attribute marker not found'
    @lex.forward constants.attributeMarker.length
    
    count = @lex.uint32()
    if count is 0 and @lex.uint32() isnt constants.zeroMarker
      throw new Error 'No attributes and no absent marker present'
    res = {}
    for [0...count]
      attr = @attr()
      res[attr.name] = attr.value
    res
  
  # name  nc_type  nelems  [values ...]
  attr: =>
    name: @name()
    value: @lex.readerForType(@lex.type()) @lex.uint32()
  
  # ABSENT | NC_VARIABLE nelems  [var ...]
  var_list: =>
    if @lex.match constants.zeroMarker
      @lex.forward constants.zeroMarker.length
      return {}
    
    if not @lex.match constants.variableMarker
      throw new Error 'Variable marker not found'
    @lex.forward constants.variableMarker.length
    
    count = @lex.uint32()
    if count is 0 and @lex.uint32() isnt constants.zeroMarker
      throw new Error 'No variables and no absent marker present'
    res = {}
    for [0...count]
      variable = @var()
      res[variable.name] = variable.value
    res
  
  # name  nelems  [dimid ...]  vatt_list  nc_type  vsize  begin
  var: =>
    name: @name()
    value:
      dimensions: [0...@lex.uint32()].map => @lex.uint32()
      attributes: @vatt_list()
      type: @lex.type()
      size: @lex.uint32()
      offset: @lex.uint32()

module.exports = Header
