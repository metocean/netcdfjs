decoder = new require('text-encoding').TextDecoder 'utf-8'

# Extracted from https://github.com/jDataView/jDataView/blob/master/src/jdataview.js

pow2 = (n) ->
  if n >= 0 and n < 31 then 1 << n else pow2[n] or (pow2[n] = 2 ** n)

writeFloat = (value, mantSize, expSize) ->
  signBit = if value < 0 then 1 else 0
  exponent = undefined
  mantissa = undefined
  eMax = ~(-1 << expSize - 1)
  eMin = 1 - eMax
  if value < 0
    value = -value
  if value == 0
    exponent = 0
    mantissa = 0
  else if isNaN(value)
    exponent = 2 * eMax + 1
    mantissa = 1
  else if value == Infinity
    exponent = 2 * eMax + 1
    mantissa = 0
  else
    exponent = Math.floor(Math.log(value) / Math.LN2)
    if exponent >= eMin and exponent <= eMax
      mantissa = Math.floor((value * pow2(-exponent) - 1) * pow2(mantSize))
      exponent += eMax
    else
      mantissa = Math.floor(value / pow2(eMin - mantSize))
      exponent = 0
  b = []
  while mantSize >= 8
    b.push mantissa % 256
    mantissa = Math.floor(mantissa / 256)
    mantSize -= 8
  exponent = exponent << mantSize | mantissa
  expSize += mantSize
  while expSize >= 8
    b.push exponent & 0xff
    exponent >>>= 8
    expSize -= 8
  b.push signBit << expSize | exponent
  b

module.exports =
  float: (value) -> writeFloat value, 23, 8
  double: (value) -> writeFloat value, 52, 11