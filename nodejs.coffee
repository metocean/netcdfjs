fs = require 'fs'
netcdf = require './index'
#buf = fs.readFileSync './examples/singledim.nc', encoding: null
buf = fs.readFileSync './examples/madis-maritime.nc', encoding: null
data = new Uint8Array buf
header = netcdf.header data
body = netcdf.body data, header, 0
console.log JSON.stringify body, null, 2