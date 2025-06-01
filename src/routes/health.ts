import { Router } from 'express';
import { AppDataSource } from '../database';

const router = Router();

router.get('/', async (req, res) => {
  try {
    // Check database connection
    const isDatabaseConnected = AppDataSource.isInitialized;

    res.json({
      status: 'healthy',
      timestamp: new Date().toISOString(),
      database: {
        connected: isDatabaseConnected
      }
    });
  } catch (error) {
    console.error('Health check error:', error);
    res.status(500).json({
      status: 'unhealthy',
      error: 'Health check failed'
    });
  }
});

export const healthRouter = router; 