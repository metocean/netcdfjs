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

file = './examples/s20150211_12z.nc'
b = readrandom file

start = process.hrtime()
netcdf.header b, (header) ->
  delta = process.hrtime start
  console.log "#{delta[0]}s #{delta[1] / 1000000}ms"
  #console.log JSON.stringify header, null, 2
