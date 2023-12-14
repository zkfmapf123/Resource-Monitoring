import winston, { format } from 'winston'
const { combine, timestamp, json, prettyPrint } = winston.format

class Logger {
  private logger: winston.Logger

  constructor() {
    this.logger = winston.createLogger({
      format: combine(timestamp({ format: 'YYYY-MM-DD hh:mm:ss' }), prettyPrint(), format.splat(), format.simple(), json()),
      transports: [
        new winston.transports.Console(),
        new winston.transports.File({ filename: 'logs/error.log', level: 'error' }),
        new winston.transports.File({ filename: 'logs/debug.log', level: 'debug' }),
        new winston.transports.File({ filename: 'logs/combined.log' }),
      ],
    })
  }

  public info(...message: any[]) {
    this.logger.info(`${process.env.LABEL} => ${message}`)
  }

  public error(...message: any[]) {
    this.logger.error(`${process.env.LABEL} => ${message}`)
  }

  public debug(...message: any[]) {
    this.logger.debug(`${process.env.LABEL} => ${message}`)
  }

  public warn(...message: any[]) {
    this.logger.warn(`${process.env.LABEL} => ${message}`)
  }
}

export const logger = new Logger()
