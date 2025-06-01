import { Router } from 'express';
import { AppDataSource, TestDataSource } from '../database';
import { Transaction, TransactionStatus } from '../entities/Transaction';
import { z } from 'zod';
import { v4 as uuidv4 } from 'uuid';

export const checkoutRouter = Router();

// Validation schema for checkout request
const checkoutSchema = z.object({
  amount: z.number().positive(),
  email: z.string().email()
});

checkoutRouter.post('/', async (req, res) => {
  try {
    console.log('Received checkout request:', req.body);
    const { amount, email } = checkoutSchema.parse(req.body);

    const dataSource = process.env.NODE_ENV === 'test' ? TestDataSource : AppDataSource;
    const repository = dataSource.getRepository(Transaction);

    const transaction = repository.create({
      transaction_id: uuidv4(),
      email,
      amount,
      status: TransactionStatus.PENDING
    });

    await repository.save(transaction);

    // TODO: In production, this would call the actual Coinbase Commerce API
    // For now, just simulate the response
    const paymentUrl = `https://fake.coinbase.com/pay/${transaction.transaction_id}`;

    res.json({
      success: true,
      transaction_id: transaction.transaction_id,
      status: transaction.status,
      payment_url: paymentUrl
    });
  } catch (error) {
    console.error('Checkout error:', error);
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: 'Invalid request data', details: error.errors });
    }
    // Generic error for anything else
    res.status(500).json({ error: 'Internal server error' });
  }
}); 