import { config } from 'dotenv';
import { createLogger, format, transports } from 'winston';
import app from './app';
import { setupDatabase } from './database';

// Load environment variables
config();

// Set up logging - probably overkill for this but useful for debugging
const logger = createLogger({
  level: 'info',
  format: format.combine(
    format.timestamp(),
    format.json()
  ),
  transports: [
    new transports.Console(),
    new transports.File({ filename: 'error.log', level: 'error' }),
    new transports.File({ filename: 'combined.log' })
  ]
});

const port = process.env.PORT || 3000;

// Initialize database and start server
async function startServer() {
  try {
    await setupDatabase();
    app.listen(port, () => {
      logger.info(`🚀 Crypto Checkout Simulator running on port ${port}`);
      logger.info(`📋 Health check: http://localhost:${port}/health`);
      logger.info(`💳 Checkout API: http://localhost:${port}/checkout`);
      logger.info(`🔔 Webhook API: http://localhost:${port}/webhook`);
    });
  } catch (error) {
    logger.error('Failed to start server:', error);
    process.exit(1);
  }
}

startServer(); 