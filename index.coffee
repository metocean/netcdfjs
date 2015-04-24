Body = require './src/body'

module.exports =
  header: require './src/header'
  body: (data, header, index) ->
    new Body(data).body header, index