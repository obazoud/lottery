vows = require 'vows'
request = require 'request'
assert = require 'assert'

describe = (name, bat) -> vows.describe(name).addBatch(bat).export(module)

t = (fn) ->
  (args...) ->
    fn.apply this, args
    return

describe "Lottery HTTP"
  "When using http":
    "and GET to /healthCheck":
      topic: t ->
        request
          uri: "http://localhost:3000/healthCheck"
          method: "GET"
        , @callback

      "should respond with 200": (err, res, body) ->
        assert.equal res.statusCode, 200

      "should respond with ok": (err, res, body) ->
        assert.equal body, "ok"

      "should respond with X-Powered-By header": (err, res, body) ->
        assert.include res.headers, 'x-powered-by'

    "and GET to /":
      topic: t ->
        request
          uri: "http://localhost:3000/"
          method: "GET"
        , @callback

      "should respond with 200": (err, res, body) ->
        assert.equal res.statusCode, 200

      "should respond with X-Powered-By header": (err, res, body) ->
        assert.include res.headers, 'x-powered-by'

    "and GET Socket.IO javascript":
      topic: t ->
        request
          uri: "http://localhost:3000/socket.io/socket.io.js"
          method: "GET"
        , @callback

      "should respond with 200": (err, res, body) ->
        assert.equal res.statusCode, 200

      "should respond with javascript content type header": (err, res, body) ->
        assert.equal res.headers['content-type'], 'application/javascript'

    "and GET JQuery javascript":
      topic: t ->
        request
          uri: "http://localhost:3000/js/vendor/jquery.min.js"
          method: "GET"
        , @callback

      "should respond with 200": (err, res, body) ->
        assert.equal res.statusCode, 200

      "should respond with javascript content type header": (err, res, body) ->
        assert.equal res.headers['content-type'], 'application/javascript'

    "and GET Twitter Bootstrap CSS":
      topic: t ->
        request
          uri: "http://localhost:3000/css/bootstrap.min.css"
          method: "GET"
        , @callback

      "should respond with 200": (err, res, body) ->
        assert.equal res.statusCode, 200

      "should respond with css content type header": (err, res, body) ->
        assert.equal res.headers['content-type'], 'text/css; charset=UTF-8'

    "and GET Lottery CSS":
      topic: t ->
        request
          uri: "http://localhost:3000/css/styles.css"
          method: "GET"
        , @callback

      "should respond with 200": (err, res, body) ->
        assert.equal res.statusCode, 200

      "should respond with css content type header": (err, res, body) ->
        assert.equal res.headers['content-type'], 'text/css; charset=UTF-8'

    "and GET Lottery Javascript":
      topic: t ->
        request
          uri: "http://localhost:3000/js/lottery.js"
          method: "GET"
        , @callback

      "should respond with 200": (err, res, body) ->
        assert.equal res.statusCode, 200

      "should respond with javascript content type header": (err, res, body) ->
        assert.equal res.headers['content-type'], 'application/javascript'
