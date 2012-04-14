vows    = require 'vows'
request = require 'request'
assert  = require 'assert'
async   = require 'async'
api     = require '../api'
_       = require 'underscore'

require '../logger'

describe = (name, bat) -> vows.describe(name).addBatch(bat).export(module)

t = (fn) ->
  (args...) ->
    fn.apply this, args
    return

describe "Lottery API"
  "When using api":
    "and create a user with invalid nickname":
      topic: t ->
        api.createUser null, null, @callback

      "should respond invalid": (error, user) ->
        assert.equal error, "invalid"
        assert.isNull user

    "and create a user with a invalid socketId":
      topic: t ->
        api.createUser 'test', null, @callback

      "should respond true": (error, user) ->
        assert.equal error, "invalid-socketId"
        assert.isNull user

    "and create a user":
      topic: t ->
        api.createUser 'olivier', '123', @callback

      "should respond this user": (error, user) ->
        assert.isNull error
        assert.equal user.nickname, 'olivier'
        assert.equal user.socketId, '123'

    "and create two users":
      topic: t ->
        self = @
        api.createUser 'olivier', '123', (error, user) ->
          api.createUser 'olivier2', '123', self.callback

      "should respond a valid user": (error, user) ->
        assert.isNull error
        assert.equal user.nickname, 'olivier2'
        assert.equal user.socketId, '123'

    "and create too many users":
      topic: t ->
        functions = []
        functions.push (fn) ->
          api.createUser 'olivier-1', '123-1', (error, user) ->
            fn(error, 2)
        for num in [2..98]
          functions.push (i, fn) ->
            api.createUser 'olivier-' + i, '123-' + i, (error, user) ->
              fn(error, ++i)
        async.waterfall functions, @callback

      "should respond too many nicknames error": (error, user) ->
        assert.equal error, "too-many-nicknames"

    "and create javascript xss users":
      topic: t ->
        api.createUser '"><script>alert("Test")</script>', '1234', @callback

      "should respond with a sanitize user": (error, user) ->
        assert.isNull error
        assert.equal user.nickname, "\">[removed]alert&#40;\"Test\"&#41;[removed]"

    "and create html xss users":
      topic: t ->
        api.createUser '"><body bgcolor="FF0000"></body>', '1234', @callback

      "should respond with a sanitize user": (error, user) ->
        assert.isNull error
        assert.equal user.nickname, "\">&lt;body bgcolor=\"FF0000\"&gt;&lt;/body>"

    "and bet 42":
      topic: t ->
        self = @
        api.createUser 'olivier-bet', '123', (error, user) ->
          self.callback error, null if error
          self.callback null, api.bet(user.nickname, 42)

      "should respond 42": (error, bet) ->
        assert.isNull error
        assert.equal bet, 42

    "and bet twice on 42":
      topic: t ->
        functions = []
        functions.push (fn) ->
          api.createUser 'olivier-bet2', '123', (error, user) ->
            fn error, user
        functions.push (user, fn) ->
            fn null, api.bet(user.nickname, 42)
        functions.push (user, fn) ->
            fn null, api.bet(user.nickname, 42)
        async.waterfall functions, @callback

      "should respond false": (error, result) ->
        assert.isNull error
        assert.isFalse result

    "and remove user":
      topic: t ->
        functions = []
        functions.push (fn) ->
          api.createUser 'olivier-removeuser1', '1234', (error, user) ->
            fn error, user
        functions.push (user, fn) ->
          api.createUser 'olivier-removeuser2', '1235', (error, user) ->
            fn error, user
        functions.push (user, fn) ->
            fn null, api.removeUser user.nickname
        functions.push (user, fn) ->
            fn null, api.nicknames()
        async.waterfall functions, @callback

      "should respond false": (error, nicknames) ->
        assert.isNull error
        assert.equal  _.size(_.filter nicknames, (nickname) ->
          nickname == 'olivier-removeuser1'
        ), 1
        assert.equal  _.size(_.filter nicknames, (nickname) ->
          nickname == 'olivier-removeuser2'
        ), 0
