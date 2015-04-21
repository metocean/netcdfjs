# NetCDF
Read NetCDF files in the browser or with Node.js

## Status
Header parsing is mostly working, however the new sample file is broke broke broke!

## Reference
[NetCDF Documentation](https://www.unidata.ucar.edu/software/netcdf/docs/)
Includes [FAQ](https://www.unidata.ucar.edu/software/netcdf/docs/ncFAQ.html), [examples](https://www.unidata.ucar.edu/software/netcdf/docs/examples.html), [C library](https://github.com/Unidata/netcdf-c)

## API Inspiration
- [xray](http://xray.readthedocs.org/)
- [Pandas](http://pandas.pydata.org/)
- [CDMS](http://esg.llnl.gov/cdat/cdms_html/cdms-2.htm)

## Todo
- Implement the [CDM](http://www.unidata.ucar.edu/software/thredds/current/netcdf-java/CDM/)
- Data parsing
- Arbitrary data slicing and querying
- Tests!



The record size, denoted by recsize below, is the sum of the vsize fields of record variables (variables that use the unlimited dimension), using the actual value determined by dimension sizes and variable type in case the vsize field is too small for the variable size.

To compute the offset of a value relative to the beginning of a variable, it is helpful to precompute a “product vector” from the dimension lengths. Form the products of the dimension lengths for the variable from right to left, skipping the leftmost (record) dimension for record variables, and storing the results as the product vector for each variable.

For example:

Non-record variable:

dimension lengths: [ 5 3 2 7] product vector: [210 42 14 7]

Record variable:

dimension lengths: [0 2 9 4] product vector: [0 72 36 4]

At this point, the leftmost product, when rounded up to the next multiple of 4, is the variable size, vsize, in the grammar above. For example, in the non-record variable above, the value of the vsize field is 212 (210 rounded up to a multiple of 4). For the record variable, the value of vsize is just 72, since this is already a multiple of 4.

Let coord be the array of coordinates (dimension indices, zero-based) of the desired data value. Then the offset of the value from the beginning of the file is just the file offset of the first data value of the desired variable (its begin field) added to the inner product of the coord and product vectors times the size, in bytes, of each datum for the variable. Finally, if the variable is a record variable, the product of the record number, 'coord[0]', and the record size, recsize, is added to yield the final offset value.

A special case: Where there is exactly one record variable, we drop the requirement that each record be four-byte aligned, so in this case there is no record padding.