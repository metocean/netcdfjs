binary = require './binary'

module.exports =
  byte: binary.readByte
  char: binary.readChar
  short: binary.readShort
  int: binary.readInt
  float: binary.readFloat
  double: binary.readDouble