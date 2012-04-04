util = require 'util'
_ = require 'underscore'

EventEmitter = require('events').EventEmitter
controller = new EventEmitter()
module.exports = controller

users = {}
draw = {}
count = 1
timer = 14

module.exports.findUserByNickname = (nickname) ->
  users[nickname]

module.exports.isValidNickname = (nickname) ->
  return true if nickname
  false

module.exports.isTooManyNicknames = () ->
  return true unless _.size(users) <= 100
  false

module.exports.createUser = (nickname, socketId) ->
  users[nickname] = { nickname : nickname, socketId : socketId }

module.exports.bet = (nickname, number) ->
  users[nickname].bet = number if nickname

module.exports.usersbets = () ->
  bets = _.map users, (user, username) ->
    user.bet

module.exports.removeUserByNickname = (nickname) ->
  delete users[nickname]

module.exports.removeUserBySocketId = (socketId) ->
  _.each users, (username, user) ->
    delete users[username] if user.socketId == socketId

module.exports.nicknames = () ->
  nicknames = for key, value of users
    "#{key}"

module.exports.clock = () ->
  if (timer <= 0)
    timer = 14
  else
    timer--

  switch timer
    when 0 then lotteryDraw()
    when 2 then lotteryFreeze()
    when 13 then lotteryUnfreeze()

  controller.emit "lottery clock", { timer : timer }

lotteryDraw = ->
  process.nextTick () ->
    _.each users, (user) ->
      delete user.bet
  controller.emit "lottery draw show", draw

lotteryUnfreeze = ->
  controller.emit "lottery unfreeze", { state : 'unfreeze' }

lotteryFreeze = ->
  controller.emit "lottery freeze", { state : 'freeze' }
  rand = parseInt(Math.random() * 100) + 1
  usersMap = _.map users, (user, username) ->
    user
  winners = _.filter usersMap, (user) ->
    user.bet == rand

  controller.emit "lottery draw", { draw : rand }
  draw = { draw : rand, date: new Date(), winners: winners}

controller.emit "lottery clock", { timer : timer }
