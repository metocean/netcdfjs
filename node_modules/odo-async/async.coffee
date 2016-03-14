bind = ->
  delay = if typeof setImmediate is 'function'
    (fn) -> setImmediate fn
  else
    (fn) -> setTimeout fn, 0

  series: (tasks, callback) ->
    tasks = tasks.slice 0
    next = (cb) ->
      return cb() if tasks.length is 0
      task = tasks.shift()
      task -> delay -> next cb
    result = (cb) -> next cb
    result(callback) if callback?
    result

  parallel: (tasks, callback) ->
    count = tasks.length
    result = (cb) ->
      return cb() if count is 0
      for task in tasks
        task ->
          count--
          cb() if count is 0
    result(callback) if callback?
    result

  delay: delay

if define?
  define [], bind
else if module?
  module.exports = bind()
else
  window.async = bind()