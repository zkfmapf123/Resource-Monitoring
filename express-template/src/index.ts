import express from 'express'
import morgan from 'morgan'
import { envConfig, HttpConnector } from './configs'
import { healthController } from './domains'

const { PORT } = envConfig.getEnv()
const httpConnect = new HttpConnector(express(), PORT, envConfig.getEnv())

httpConnect
  // .setConfigs(dbConfig)
  .setHTTPMiddleware(morgan('tiny'))
  .setHTTPMiddleware(express.json())
  .setHTTPMiddleware(express.urlencoded({ extended: false }))
  .setControllers([healthController])
  .setErrorHandling()
  .start(process.env.NODE_ENV === 'dev' ? false : true)
