decoder = new require('text-encoding').TextDecoder 'utf-8'

# Extracted from https://github.com/jDataView/jDataView/blob/master/src/jdataview.js

pow2 = (n) ->
  if n >= 0 and n < 31 then 1 << n else pow2[n] or (pow2[n] = 2 ** n)

hex = (b) ->
  res = b.toString 16
  res = "0#{res}" if res.length is 1
  res

module.exports =
  byte: (b, i) ->
    i = 0 if !i?
    b[i]
  char: (b, i) ->
    i = 0 if !i?
    String.fromCharCode b[i]
  short: (b, i) ->
    i = 0 if !i?
    b[i] << 8 | b[i+1]
  int: (b, i) ->
    i = 0 if !i?
    b[i] << 24 | b[i+1] << 16 | b[i+2] << 8 | b[i+3]
  bigint: (b, i) ->
    # totally gross
    i = 0 if !i?
    res = ''
    for j in [0...8]
      res += hex b[i + j]
    return parseFloat res
  float: (b, i) ->
    i = 0 if !i?
    sign = 1 - 2 * (b[i] >> 7)
    exponent = (b[i] << 1 & 0xff | b[i+1] >> 7) - 127
    mantissa = (b[i+1] & 0x7f) << 16 | b[i+2] << 8 | b[i+3]
    if exponent is 128
      if mantissa isnt 0
        return NaN
      else
        return sign * Infinity
    if exponent is -127
      return sign * mantissa * pow2(-126 - 23)
    sign * (1 + mantissa * pow2(-23)) * pow2(exponent)
  double: (b, i) ->
    i = 0 if !i?
    sign = 1 - 2 * (b[i] >> 7)
    exponent = ((b[i] << 1 & 0xff) << 3 | b[i+1] >> 4) - ((1 << 10) - 1)
    mantissa = (b[i+1] & 0x0f) * pow2(48) + b[i+2] * pow2(40) + b[i+3] * pow2(32) + b[i+4] * pow2(24) + b[i+5] * pow2(16) + b[i+6] * pow2(8) + b[i+7]
    if exponent is 1024
      if mantissa isnt 0
        return NaN
      else
        return sign * Infinity
    if exponent is -1023
      return sign * mantissa * pow2(-1022 - 52)
    sign * (1 + mantissa * pow2(-52)) * pow2(exponent)
  string: (b) ->
    decoder.decode b