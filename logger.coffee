winston = require 'winston'

# Logger
console.log "Initialize logger (winston)..."
global.logger = new winston.Logger(
  transports: [ new (winston.transports.Console)({
    "timestamp": true
    })
  ]
)

logger.cli().transports.console.timestamp = true
