readfile = require './src/readfile'
readstream = require './src/readstream'
readrandom = require './src/readrandom'
netcdf = require './index'

printdelta = (delta) ->
  "#{delta[0]}s #{delta[1]/1000000}ms"

file = '/Users/tcoats/Desktop/abis20141222_18z_uds.nc'
start = process.hrtime()
#file = './examples/s20150211_12z.nc'
headerbuffer = readstream file

netcdf.header headerbuffer, (header) ->
  console.log JSON.stringify header, null, 2
  headertime = process.hrtime start
  
  start = process.hrtime()
  recordbuffer = readrandom file
  netcdf.variable header, recordbuffer, 'lat', (err, data) ->
    return console.error err if err?
    variabletime = process.hrtime start
    console.log data
    #console.log records.wdir
    console.log "header parsed in #{printdelta headertime}"
    console.log "variable parsed in #{printdelta variabletime}"
  
  # start = process.hrtime()
  # recordbuffer = readrandom file
  # netcdf.records header, recordbuffer, (err, records) ->
  #   return console.error err if err?
  #   recordstime = process.hrtime start
  #   console.log "#{header.records.number} records"
  #   console.log Object.keys records
  #   console.log "header parsed in #{printdelta headertime}"
  #   console.log "records parsed in #{printdelta recordstime}"