import request from 'supertest';
import app from '../app';
import { setupTestDatabase, clearTestDatabase, closeTestDatabase, TestDataSource } from './setup';
import { Transaction, TransactionStatus } from '../entities/Transaction';
import { v4 as uuidv4 } from 'uuid';

beforeAll(async () => {
  await setupTestDatabase();
});

beforeEach(async () => {
  await clearTestDatabase();
});

afterAll(async () => {
  await closeTestDatabase();
});

describe('Webhook API', () => {
  it('should update transaction status to completed', async () => {
    // Create a transaction first
    const repository = TestDataSource.getRepository(Transaction);
    const transaction = repository.create({
      transaction_id: uuidv4(),
      email: 'test@example.com',
      amount: 100,
      status: TransactionStatus.PENDING
    });
    await repository.save(transaction);

    const response = await request(app)
      .post('/webhook')
      .send({
        transaction_id: transaction.transaction_id,
        status: 'completed'
      });

    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty('success', true);
    expect(response.body.transaction.status).toBe(TransactionStatus.COMPLETED);

    // Verify the transaction was updated in the database
    const updatedTransaction = await repository.findOne({
      where: { transaction_id: transaction.transaction_id }
    });
    expect(updatedTransaction?.status).toBe(TransactionStatus.COMPLETED);
  });

  it('should update transaction status to failed', async () => {
    // Create a transaction first
    const repository = TestDataSource.getRepository(Transaction);
    const transaction = repository.create({
      transaction_id: uuidv4(),
      email: 'test@example.com',
      amount: 100,
      status: TransactionStatus.PENDING
    });
    await repository.save(transaction);

    const response = await request(app)
      .post('/webhook')
      .send({
        transaction_id: transaction.transaction_id,
        status: 'failed'
      });

    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty('success', true);
    expect(response.body.transaction.status).toBe(TransactionStatus.FAILED);

    // Verify the transaction was updated in the database
    const updatedTransaction = await repository.findOne({
      where: { transaction_id: transaction.transaction_id }
    });
    expect(updatedTransaction?.status).toBe(TransactionStatus.FAILED);
  });

  it('should handle non-existent transaction', async () => {
    const response = await request(app)
      .post('/webhook')
      .send({
        transaction_id: 'non-existent-id',
        status: 'completed'
      });

    expect(response.status).toBe(404);
    expect(response.body).toHaveProperty('error', 'Transaction not found');
  });

  it('should validate webhook payload', async () => {
    const response = await request(app)
      .post('/webhook')
      .send({
        transaction_id: 'some-id',
        status: 'invalid_status'
      });

    expect(response.status).toBe(400);
    expect(response.body).toHaveProperty('error', 'Invalid request data');
    expect(response.body.details).toBeDefined();
  });
}); 