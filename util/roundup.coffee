module.exports = (num, multiple) ->
  return num if multiple is 0
  remainder = num % multiple
  return num if remainder is 0
  num + multiple - remainder