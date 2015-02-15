fs = require 'fs'
netcdf = require './index'
buf = fs.readFileSync './examples/s20150211_12z.nc', encoding: null
data = new Uint8Array buf
header = netcdf.header data
content = netcdf.body data, header, 2
console.log JSON.stringify content, null, 2