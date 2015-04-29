# Reader interfaces. These file can be included individually.
# These methods require inputs from the fs folder e.g. readstream

module.exports =
  readheader: require './structure/readheader'
  readrecords: require './structure/readrecords'
  readvariable: require './structure/readvariable'