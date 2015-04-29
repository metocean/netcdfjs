# Read all the header information from a NetCDF file.
# Pre-computes variable dimension sizes and record sizes and offsets

roundup = require '../util/roundup'
type = require '../util/type'
async = require 'odo-async'

marker =
  streaming: -1
  zero: 0
  dimension: 10
  variable: 11
  attribute: 12

module.exports = (buffer, callback) ->
  one = require('../stream/readbinary') buffer
  many = require('../stream/readarray') buffer
  fill = require('../stream/readarrayfill') buffer
  readtype = require('../stream/readtype') buffer
  
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
            var_list result.version.number, (res) ->
              result.variables = res
              buffer.close()
              cb precompute result
  
  precompute = (header) ->
    for dim in header.dimensions
      if dim.length is null
        header.records.dimension = dim.index
        break
    
    precompute_size v, header for _, v of header.variables
    
    header.records.hassingle = false
    for _, v of header.variables
      if v.isrecord
        if header.hassinglerecord
          header.records.hassingle = no
          break
        header.records.hassingle = yes
    
    header.records.size = 0
    header.records.offset = Infinity
    for _, v of header.variables
      continue unless v.isrecord
      header.records.offset = Math.min v.offset, header.records.offset
      header.records.size += v.size
    
    unless header.hassinglerecord
      header.records.size = roundup header.records.size, 4
    
    header.records.offsets = {}
    for name, v of header.variables
      continue unless v.isrecord
      header.records.offsets[name] = v.offset - header.records.offset
    
    header
  
  precompute_size = (variable, header) ->
    indexes = variable.dimensions
    variable.dimensions =
        indexes: indexes
        lengths: []
        sizes: []
        products: []
    
    return if indexes.length is 0
    
    variable.dimensions.lengths = indexes.map (i) ->
      header.dimensions[i].length
    
    product = 1
    products = variable.dimensions.lengths.slice(0).reverse().map (length) ->
      product *= length
      product
    products = products.reverse()
    variable.dimensions.products = products
    
    sizes = products.map (p) -> p * variable.size
    variable.dimensions.sizes = products.map (p) ->
      p * type.size variable.type
    
    variable.isrecord = no
    if header.dimensions[indexes[0]].length is null
      variable.isrecord = yes
      # remove record dimension
      variable.dimensions.indexes.shift()
      variable.dimensions.lengths.shift()
      variable.dimensions.products.shift()
      variable.dimensions.sizes.shift()
    
    variable.size = type.size variable.type
    if variable.dimensions.indexes.length isnt 0
      variable.size = variable.dimensions.sizes[0]
  
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
      readtype.type (t) ->
        one.int (count) ->
          readtype.reader(t) count, (value) ->
            cb
              name: name
              value: value
  
  # ABSENT | NC_VARIABLE nelems  [var ...]
  var_list = (version, cb) ->
    one.int (mark) ->
      if mark is marker.zero
        return one.int -> cb {}
      
      if mark isnt marker.variable
        throw new Error 'Attribute marker not found'
      
      one.int (count) ->
        result = {}
        tasks = [0...count].map ->
          (cb) -> variable version, (variable) ->
            result[variable.name] = variable.value
            cb()
        async.series tasks, -> cb result
  
  # name  nelems  [dimid ...]  vatt_list  nc_type  vsize  begin
  variable = (version, cb) ->
    name (name) ->
      console.log name
      one.int (dimnum) ->
        dimindexes = []
        tasks = [0...dimnum].map ->
          (cb) -> one.int (index) ->
            dimindexes.push index
            cb()
        async.series tasks, ->
          vatt_list (attributes) ->
            readtype.type (t) ->
              one.bigint (size) ->
                if version is 2
                  return one.int (offset) ->
                    cb
                      name: name
                      value:
                        dimensions: dimindexes
                        attributes: attributes
                        type: t
                        size: size
                        offset: offset
                
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