# fs = require 'fs'
# buf = fs.readFileSync './examples/singledim.nc', encoding: null
# data = new Uint8Array buf
# netcdf = require './index'
# header = netcdf.header data
# body = netcdf.body data, header, 0
# console.log JSON.stringify body, null, 2

readstream = require './src/readstream'

#b = readstream './examples/singledim.nc'
b = readstream './examples/WMI_Lear.nc'

netcdf = require './index'

netcdf.header b, (res) ->
  console.log JSON.stringify res, null, 2
