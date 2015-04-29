# fs = require 'fs'
# buf = fs.readFileSync './examples/singledim.nc', encoding: null
# data = new Uint8Array buf
# netcdf = require './index'
# header = netcdf.header data
# body = netcdf.body data, header, 0
# console.log JSON.stringify body, null, 2

# fs = require 'fs'
# buf = fs.readFileSync './examples/singledim.nc', encoding: null
# data = new Uint8Array buf
# netcdf = require './index'
# header = netcdf.header data
# body = netcdf.body data, header, 0
# console.log JSON.stringify body, null, 2



readfile = require './src/readfile'
readstream = require './src/readstream'
readrandom = require './src/readrandom'
netcdf = require './index'

# file = '/Users/tcoats/Desktop/abis20141222_18z_uds.nc'
file = './examples/WMI_Lear.nc'
headerbuffer = readstream file
recordbuffer = readrandom file

netcdf.header headerbuffer, (header) ->
  console.log JSON.stringify header, null, 2
  netcdf.records header, recordbuffer, (err, records) ->
    console.log Object.keys records