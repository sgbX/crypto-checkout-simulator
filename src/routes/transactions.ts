import { Router } from 'express';
import { AppDataSource, TestDataSource } from '../database';
import { Transaction } from '../entities/Transaction';

export const transactionsRouter = Router();

transactionsRouter.get('/', async (req, res) => {
  try {
    const dataSource = process.env.NODE_ENV === 'test' ? TestDataSource : AppDataSource;
    const repository = dataSource.getRepository(Transaction);
    const transactions = await repository.find();
    res.json(transactions);
  } catch (error) {
    console.error('Error fetching transactions:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

transactionsRouter.get('/:id', async (req, res) => {
  try {
    const dataSource = process.env.NODE_ENV === 'test' ? TestDataSource : AppDataSource;
    const repository = dataSource.getRepository(Transaction);
    const transaction = await repository.findOne({
      where: { transaction_id: req.params.id }
    });

    if (!transaction) {
      return res.status(404).json({ error: 'Transaction not found' });
    }

    res.json(transaction);
  } catch (error) {
    console.error('Error fetching transaction:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
}); 