readstream = require '../fs/readstream'
readrandom = require '../fs/readrandom'
netcdf = require '../'

file = './examples/WMI_Lear.nc'
headerbuffer = readstream file

# Read the header of a NetCDF file
netcdf.readheader headerbuffer, (header) ->
  console.log JSON.stringify header, null, 2

  randombuffer = readrandom file

  # Read a variable
  netcdf.readvariable header, randombuffer, 'lat', (err, data) ->
    return console.error err if err?
    console.log data

  # Read records
  netcdf.readrecords header, randombuffer, (err, data) ->
    return console.error err if err?
    console.log data