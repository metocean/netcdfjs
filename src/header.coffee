roundup = require './roundup'
async = require 'odo-async'

marker =
  streaming: -1
  zero: 0
  dimension: 10
  variable: 11
  attribute: 12

module.exports = (buffer, callback) ->
  one = require('./primatives') buffer
  many = require('./arrays') buffer
  fill = require('./arraysfill') buffer
  type = require('./types') buffer
  
  header = (cb) ->
    result = {}
    magic (res) ->
      result.version = res
      numrecs (res) ->
        result.records = res
        dim_list (res) ->
          result.dimensions = res
          gatt_list (res) ->
            result.attributes = res
            var_list (res) ->
              result.variables = res
              buffer.close()
              cb precompute result
  
  precompute = (header) ->
    for dim in header.dimensions
      if dim.length is null
        header.records.dimension = dim.index
        break
    
    precompute_size v, header for _, v of header.variables
    
    header.hassinglerecord = false
    for _, v of header.variables
      if v.isrecord
        if header.hassinglerecord
          header.hassinglerecord = no
          break
        header.hassinglerecord = yes
    
    unless header.hassinglerecord
      for _, v of header.variables
        v.size = roundup v.size, 4
    
    header.recordsize = 0
    for _, v of header.variables
      continue unless v.isrecord
      header.recordsize += v.size
    
    header
  
  precompute_size = (variable, header) ->
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
    variable.dimensions.sizes = products.map (p) ->
      p * type.size variable.type
    
    variable.isrecord = header.dimensions[indexes[0]].length is null
    
    size = type.size variable.type
    if variable.dimensions.indexes.length < 2
      return variable.size = size
    size = if variable.isrecord
        variable.dimensions.sizes[1]
      else
        variable.dimensions.sizes[0]
    variable.size = size
  
  # 'C'  'D'  'F'  VERSION
  magic = (cb) ->
    many.char 3, (magicstring) ->
      throw new Error 'Not a valid NetCDF file ' + magicstring if magicstring isnt 'CDF'
    one.byte (version) ->
      unless version in [1, 2, 3]
        throw new Error "Unknown NetCDF format (version #{version})"
      description = 'Classic format' if version is 1
      description = '64 bit offset format' if version is 2
      cb
        number: version
        description: description
  
  numrecs = (cb) ->
    one.int (count) ->
      if count is marker.streaming
        return cb type: 'streaming'
      cb
        type: 'fixed'
        number: count
  
  # ABSENT | NC_DIMENSION  nelems  [dim ...]
  dim_list = (cb) ->
    one.int (mark) ->
      if mark is marker.zero
        return one.int -> cb {}
      
      if mark isnt marker.dimension
        throw new Error 'Dimension marker not found'
      
      one.int (count) ->
        result = []
        tasks = [0...count].map (index) ->
          (cb) -> dim (res) ->
            res.index = index
            result.push res
            cb res
        async.series tasks, -> cb result
  
  dim = (cb) ->
    name (name) ->
      one.int (length) ->
        length = null if length is 0
        cb
          name: name
          length: length
  
  name = (cb) ->
    one.int (length) ->
      fill.char length, cb
  
  gatt_list = (cb) -> att_list cb
  vatt_list = (cb) -> att_list cb
  
  # ABSENT | NC_ATTRIBUTE  nelems  [attr ...]
  att_list = (cb) ->
    one.int (mark) ->
      if mark is marker.zero
        return one.int -> cb {}
      
      if mark isnt marker.attribute
        throw new Error 'Attribute marker not found'
      
      one.int (count) ->
        result = {}
        tasks = [0...count].map ->
          (cb) -> attr (attr) ->
            result[attr.name] = attr.value
            cb()
        async.series tasks, -> cb result
  
  # name  nc_type  nelems  [values ...]
  attr = (cb) ->
    name (name) ->
      type.type (t) ->
        one.int (count) ->
          type.reader(t) count, (value) ->
            cb
              name: name
              value: value
  
  # ABSENT | NC_VARIABLE nelems  [var ...]
  var_list = (cb) ->
    one.int (mark) ->
      if mark is marker.zero
        return one.int -> cb {}
      
      if mark isnt marker.variable
        throw new Error 'Attribute marker not found'
      
      one.int (count) ->
        result = {}
        tasks = [0...count].map ->
          (cb) -> variable (variable) ->
            result[variable.name] = variable.value
            cb()
        async.series tasks, -> cb result
  
  # name  nelems  [dimid ...]  vatt_list  nc_type  vsize  begin
  variable = (cb) ->
    name (name) ->
      one.int (dimnum) ->
        dimindexes = []
        tasks = [0...dimnum].map ->
          (cb) -> one.int (index) ->
            dimindexes.push index
            cb()
        async.series tasks, ->
          vatt_list (attributes) ->
            type.type (t) ->
              one.int (size) ->
                one.int (offset) ->
                  cb
                    name: name
                    value:
                      dimensions: dimindexes
                      attributes: attributes
                      type: t
                      size: size
                      offset: offset
  
  header (res) -> callback res