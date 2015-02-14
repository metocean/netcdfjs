fs = require 'fs'
netcdf = require './index'
buf = fs.readFileSync './examples/s20150211_12z.nc', encoding: null
data = new Uint8Array buf
header = netcdf.header data
content = netcdf.data header, data
console.log JSON.stringify content, null, 2