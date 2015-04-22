pow2 = (n) ->
  if n >= 0 and n < 31 then 1 << n else pow2[n] or (pow2[n] = 2 ** n)

module.exports =
  float: (b) ->
    sign = 1 - 2 * (b[0] >> 7)
    exponent = (b[0] << 1 & 0xff | b[1] >> 7) - 127
    mantissa = (b[1] & 0x7f) << 16 | b[2] << 8 | b[3]
    if exponent == 128
      if mantissa != 0
        return NaN
      else
        return sign * Infinity
    if exponent == -127
      # Denormalized
      return sign * mantissa * pow2(-126 - 23)
    sign * (1 + mantissa * pow2(-23)) * pow2(exponent)
    
    
    # byte1 = bytes[0]
    # byte2 = bytes[1]
    # byte3 = bytes[2]
    # byte4 = bytes[3]
    # sign = if (byte1 & 128) > 0 then -1 else 1
    # exponent = (byte1 & 127) << 1 | (byte2 & 128) >> 7
    # significand = (byte2 & 127) << 16 | byte3 << 8 | byte4

    # if exponent is 255
    #   if significand
    #     return sign * Number.NaN
    #   else
    #     return sign * Number.POSITIVE_INFINITY

    # if exponent is 0
    #   return sign * 0.0 if significand is 0
    #   exponent = 1
    #   significand /= (1 << 22)
    # else
    #   significand = (significand | (1 << 23)) / (1 << 23)
    
    # sign * significand * Math.pow 2, exponent - 127
  double: (b) ->
    sign = 1 - 2 * (b[0] >> 7)
    exponent = ((b[0] << 1 & 0xff) << 3 | b[1] >> 4) - ((1 << 10) - 1)
    mantissa = (b[1] & 0x0f) * pow2(48) + b[2] * pow2(40) + b[3] * pow2(32) + b[4] * pow2(24) + b[5] * pow2(16) + b[6] * pow2(8) + b[7]
    if exponent is 1024
      if mantissa isnt 0
        return NaN
      else
        return sign * Infinity
    if exponent is -1023
      return sign * mantissa * pow2(-1022 - 52)
    sign * (1 + mantissa * pow2(-52)) * pow2(exponent)