TA = require 'typedarray'

filename = 's20150211_12z.nc'
req = new XMLHttpRequest()
req.responseType = 'arraybuffer'

req.addEventListener 'progress', (e) ->
  console.log (e.loaded / e.total).toFixed 2 if e.lengthComputable?

req.addEventListener 'load', (e) -> window.netcdf new TA.Uint8Array req.response

req.open 'GET', filename, yes
req.send null