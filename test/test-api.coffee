vows = require 'vows'
request = require 'request'
assert = require 'assert'
require '../logger'
api = require '../api'

describe = (name, bat) -> vows.describe(name).addBatch(bat).export(module)

t = (fn) ->
  (args...) ->
    fn.apply this, args
    return

describe "Lottery API"
  "When using api":
    "and valid a invalid nickname":
      topic: t ->
        @callback null, api.isValidNickname()

      "should respond false": (validate) ->
        assert.equal validate, false

    "and valid a valid nickname":
      topic: t ->
        @callback null, api.isValidNickname('test')

      "should respond true": (validate) ->
        assert.equal validate, true

    "and create a user":
      topic: t ->
        @callback null, api.createUser('olivier', '123')

      "should respond this user": (user) ->
        assert.equal user.nickname, 'olivier'
        assert.equal user.socketId, '123'

    "and create two users":
      topic: t ->
        api.createUser('olivier', '123')
        @callback null, api.isTooManyNicknames()

      "should respond isTooManyNicknames false": (success) ->
        assert.equal success, false

    "and create too many users":
      topic: t ->
        for num in [1..101]
          api.createUser('olivier' + num, '123' + num)
        @callback null, api.isTooManyNicknames()

      "should respond isTooManyNicknames true": (success) ->
        assert.equal success, true
