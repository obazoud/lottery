# uncaughtException
process.on "exit", ->
  logger.info "Ooopppss! See you soon."

process.on "uncaughtException", (err) ->
  logger.error "Caught exception: " + err
  logger.error "Stack trace: " + err.stack
  process.exit 1

# Print application informations
pkginfo = require('pkginfo')(module, 'name', 'version', 'description')
logger.info ''
logger.info '---'
logger.info "#{module.exports.description} started."
logger.info "#{module.exports.name} @ #{module.exports.version}"
logger.info '---'
logger.info ''
