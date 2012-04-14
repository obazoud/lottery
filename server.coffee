path = require 'path'
util = require 'util'

require './logger'
require './common'

# Directories
rootPath   = process.cwd()
configPath = path.join @appPath, 'config'
staticPath = path.join rootPath, 'public'
env        = process.env.NODE_ENV || 'development'

# Server
express = require('express')
app     = express.createServer()
app.configure ->
  logger.info "Express server static directory: #{staticPath}"
  app.use express.static(staticPath)
  app.use express.favicon(path.join staticPath, 'favicon.ico')
  app.use express.logger()
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router

app.configure 'development', ->
  logger.info "Express server: development environment"
  app.use express.errorHandler { dumpExceptions: true, showStack: true }

app.configure 'production', ->
  logger.info "Express server: production environment"
  app.use express.errorHandler()

app.listen process.env.PORT or 3000, '0.0.0.0', ->
  logger.info "Express server listening on port #{app.address().port}: http://0.0.0.0:#{app.address().port}"

# Routes
logger.info "Define routes"
app.get '/healthCheck', (req, res) ->
  logger.info "GET /healthCheck"
  res.send 'ok', 200

# Socket.IO
io = require('socket.io').listen app
io.configure ->
  io.enable 'browser client minification'
  io.set 'log level', 1

# Lottery API
api = require './api'

setInterval (->
  api.clock()
), 1000

# Lottery events
api.on "lottery unfreeze", (event) ->
  io.sockets.emit "lottery unfreeze", event.state

api.on "lottery freeze", (event) ->
  io.sockets.emit "lottery freeze", event.state

api.on "lottery clock", (event) ->
  io.sockets.emit "lottery clock", event

api.on "lottery draw", (event) ->
  io.sockets.emit "lottery draw", event
  # force update
  io.sockets.emit "nicknames", api.nicknames()

api.on "lottery draw show", (event) ->
  io.sockets.emit "lottery draw show", event

# Socket.IO
io.sockets.on "connection", (socket) ->
  logger.debug "#{socket.id} connect."

  socket.on "user bet", (number) ->
    logger.debug "#{socket.nickname} bets #{number}."
    api.bet socket.nickname, number
    socket.broadcast.emit "users bets", api.usersbets()

  socket.on "nickname", (nickname, callback) ->
    logger.debug "nickname #{nickname}"
    api.createUser nickname, socket.id, (error, user) ->
      if error
        logger.debug "nickname #{nickname} error: #{error} - #{user}"
        callback error
      else
        logger.debug "nickname #{nickname} is a new user."
        callback false
        socket.nickname = nickname
        socket.emit "nicknames", api.nicknames()
        socket.emit "users bets", api.usersbets()

  socket.on "disconnect", ->
    logger.debug "#{socket.nickname} #{socket.id} disconnected."
    api.removeUser socket.nickname, socket.id
    socket.broadcast.emit "nicknames", api.nicknames()
