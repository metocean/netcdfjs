var args, buffer, chalk, file, fs, netcdf, readstream, usage;

chalk = require('chalk');

fs = require('fs');

args = process.argv.slice(2);

usage = "\nUsage: " + (chalk.cyan('ncjsdump')) + " <netcdf file> [<variable>]\n\n   The default action is to print the NetCDF header\n   \n   When passed a variable name the variable's details\n   and data will be printed\n   ";

if (args.length === 0 || args.length > 2) {
  console.error(usage);
  process.exit(-1);
}

file = args[0];

readstream = require('../fs/readstream');

netcdf = require('../');

buffer = readstream(file);

netcdf.readheader(buffer, function(header) {
  var body, buf, data, variable;
  if (args.length === 1) {
    console.log(JSON.stringify(header, null, 2));
    process.exit(0);
  }
  variable = args[1];
  if (header.variables[variable] == null) {
    console.error();
    console.error("  Variable " + (chalk.cyan(variable)) + " not found");
    console.error();
    console.error("  Variables available: " + (Object.keys(header.variables).join(', ')));
    console.error();
    process.exit(-1);
  }
  fs = require('fs');
  buf = fs.readFileSync(file, {
    encoding: null
  });
  data = new Uint8Array(buf);
  body = netcdf.body(data, header, variable);
  console.log(JSON.stringify(body, null, 2));
  return process.exit(0);
});
