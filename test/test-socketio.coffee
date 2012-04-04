vows = require 'vows'
io = require 'socket.io-client'
request = require 'request'
assert = require 'assert'

describe = (name, bat) -> vows.describe(name).addBatch(bat).export(module)

t = (fn) ->
  (args...) ->
    fn.apply this, args
    return

describe "Lottery Socket.IO"
  "When using socket.io api":
    "and etablish connection":
      topic: t ->
        test = @
        socket = io.connect "http://0.0.0.0:3000", {transports: ['websocket']}
        socket.on 'connect', (value) ->
          test.callback null, value

      "should receive message": (test) ->
        assert.equal test, undefined

    "and send a nickname":
      topic: t ->
        test = @
        socket = io.connect "http://0.0.0.0:3000", {transports: ['websocket']}
        socket.emit 'nickname', 'nickname-test', (value) ->
          test.callback null, value

      "should receive false": (value) ->
        assert.equal value, false

    "and send same nickname":
      topic: t ->
        test = @
        socket = io.connect "http://0.0.0.0:3000", {transports: ['websocket']}
        socket.emit 'nickname', 'nickname-test', (value) ->
          test.callback null, value

      "should receive already-exists message": (value) ->
        assert.equal value, "already-exists"

    "and send invalid nickname":
      topic: t ->
        test = @
        socket = io.connect "http://0.0.0.0:3000", {transports: ['websocket']}
        socket.emit 'nickname', undefined, (value) ->
          test.callback null, value

      "should receive invalid message": (value) ->
        assert.equal value, "invalid"
