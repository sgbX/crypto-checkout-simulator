import { Router } from 'express';
import { AppDataSource, TestDataSource } from '../database';
import { Transaction, TransactionStatus } from '../entities/Transaction';
import { z } from 'zod';

export const webhookRouter = Router();

const webhookSchema = z.object({
  transaction_id: z.string(),
  status: z.enum(['completed', 'failed'])
});

// Added retry logic after running into some DB issues during testing
const MAX_RETRIES = 3;
const INITIAL_RETRY_DELAY = 1000; // 1 second

const delay = (ms: number) => new Promise(resolve => setTimeout(resolve, ms));

async function saveTransactionWithRetry(transactionData: Partial<Transaction>, retryCount = 0): Promise<Transaction> {
  try {
    const transactionRepository = AppDataSource.getRepository(Transaction);
    const savedTransaction = await transactionRepository.save(transactionData);
    return savedTransaction;
  } catch (error) {
    if (retryCount < MAX_RETRIES) {
      const delayMs = INITIAL_RETRY_DELAY * Math.pow(2, retryCount);
      console.log(`Retry attempt ${retryCount + 1} after ${delayMs}ms`);
      await delay(delayMs);
      return saveTransactionWithRetry(transactionData, retryCount + 1);
    }
    throw error;
  }
}

webhookRouter.post('/', async (req, res) => {
  try {
    console.log('Received webhook:', req.body);
    const { transaction_id, status } = webhookSchema.parse(req.body);

    const dataSource = process.env.NODE_ENV === 'test' ? TestDataSource : AppDataSource;
    const repository = dataSource.getRepository(Transaction);

    const transaction = await repository.findOne({
      where: { transaction_id }
    });

    if (!transaction) {
      return res.status(404).json({ error: 'Transaction not found' });
    }

    // Update status based on webhook
    transaction.status = status === 'completed' ? TransactionStatus.COMPLETED : TransactionStatus.FAILED;
    const updatedTransaction = await repository.save(transaction);

    res.json({ success: true, transaction: updatedTransaction });
  } catch (error) {
    console.error('Webhook error:', error);
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: 'Invalid request data', details: error.errors });
    }
    res.status(500).json({ error: 'Internal server error' });
  }
}); 