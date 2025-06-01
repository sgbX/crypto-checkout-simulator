import express from 'express';
import cors from 'cors';
import { checkoutRouter } from './routes/checkout';
import { webhookRouter } from './routes/webhook';
import { healthRouter } from './routes/health';
import { transactionsRouter } from './routes/transactions';
import { AppDataSource } from './database';

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Request logging middleware
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
  next();
});

// Health check endpoint
app.use('/health', healthRouter);

// API routes
app.use('/checkout', checkoutRouter);
app.use('/webhook', webhookRouter);
app.use('/transactions', transactionsRouter);

// Error handling middleware
app.use((err: Error, req: express.Request, res: express.Response, next: express.NextFunction) => {
  console.error('Error:', err.message);
  res.status(500).json({ error: 'Something went wrong!' });
});

export default app; 