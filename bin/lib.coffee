chalk = require 'chalk'
fs = require 'fs'

args = process.argv.slice 2

usage = """

Usage: #{chalk.cyan 'ncjsdump'} <netcdf file> [<variable>]

   The default action is to print the NetCDF header

   When passed a variable name the variable's details
   and data will be printed

"""

if args.length is 0 or args.length > 2
  console.error usage
  process.exit -1

file = args[0]

readstream = require '../fs/readstream'
netcdf = require '../'

buffer = readstream file
netcdf.readheader buffer, (header) ->
  if args.length is 1
    console.log JSON.stringify header, null, 2
    process.exit 0

  variable = args[1]

  if !header.variables[variable]?
    console.error()
    console.error "  Variable #{chalk.cyan variable} not found"
    console.error()
    console.error "  Variables available: #{Object.keys(header.variables).join ', '}"
    console.error()
    process.exit -1

  fs = require 'fs'
  buf = fs.readFileSync file, encoding: null
  data = new Uint8Array buf
  body = netcdf.body data, header, variable
  console.log JSON.stringify body, null, 2
  process.exit 0
