Header = require './src/header'
Body = require './src/body'

module.exports =
  header: (data) -> new Header(data).header()
  body: (data, header, index) ->
    new Body(data).body header, index