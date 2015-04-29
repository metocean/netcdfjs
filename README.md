# NetCDF
Read NetCDF files in the browser or with Node.js

## Supported
- NetCDF Classic Format
- Reading only at this stage
- 64bit Offsets (with caveats)
- Reading all record variables
- Reading a non-record variable

## Todo
1. Browser support
2. Querying
3. Tests
4. Writing NetCDF

## Example

```js
var readstream = require('netcdf/fs/readstream');
var readrandom = require('netcdf/fs/readrandom');
var netcdf = require('netcdf');

var file = './examples/WMI_Lear.nc';
var headerbuffer = readstream(file);

// Read the header of a NetCDF file
netcdf.readheader(headerbuffer, function(header) {
  console.log(JSON.stringify(header, null, 2));
  
  var randombuffer = readrandom(file);
  
  // Read a variable
  netcdf.readvariable(header, randombuffer, 'lat', function(err, data) {
    if (err != null) {
      return console.error(err);
    }
    console.log(data);
  });
  
  // Read records
  netcdf.readrecords(header, randombuffer, function(err, data) {
    if (err != null) {
      return console.error(err);
    }
    console.log(data);
  });
});
```
