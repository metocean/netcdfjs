fs = require 'fs'
netcdf = require './index'
buf = fs.readFileSync './examples/singledim.nc', encoding: null
data = new Uint8Array buf
header = netcdf.header data
console.log JSON.stringify header, null, 2