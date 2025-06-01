import request from 'supertest';
import app from '../app';
import { setupTestDatabase, clearTestDatabase, closeTestDatabase, TestDataSource } from './setup';
import { Transaction, TransactionStatus } from '../entities/Transaction';

beforeAll(async () => {
  await setupTestDatabase();
});

beforeEach(async () => {
  await clearTestDatabase();
});

afterAll(async () => {
  await closeTestDatabase();
});

describe('Checkout API', () => {
  it('should create a new checkout session', async () => {
    const response = await request(app)
      .post('/checkout')
      .send({
        amount: 100,
        email: 'test@example.com'
      });

    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty('success', true);
    expect(response.body).toHaveProperty('transaction_id');
    expect(response.body).toHaveProperty('status', TransactionStatus.PENDING);
    expect(response.body).toHaveProperty('payment_url');
    expect(response.body.payment_url).toMatch(/https:\/\/fake\.coinbase\.com\/pay\/.+/);

    // Verify transaction was saved in database
    const repository = TestDataSource.getRepository(Transaction);
    const savedTransaction = await repository.findOne({
      where: { transaction_id: response.body.transaction_id }
    });

    expect(savedTransaction).toBeDefined();
    expect(savedTransaction?.email).toBe('test@example.com');
    expect(savedTransaction?.amount).toBe(100);
    expect(savedTransaction?.status).toBe(TransactionStatus.PENDING);
  });

  it('should validate required fields', async () => {
    const response = await request(app)
      .post('/checkout')
      .send({});

    expect(response.status).toBe(400);
    expect(response.body).toHaveProperty('error', 'Invalid request data');
    expect(response.body.details).toBeDefined();
  });

  it('should validate email format', async () => {
    const response = await request(app)
      .post('/checkout')
      .send({
        amount: 100,
        email: 'invalid-email'
      });

    expect(response.status).toBe(400);
    expect(response.body).toHaveProperty('error', 'Invalid request data');
    expect(response.body.details).toBeDefined();
  });

  it('should validate positive amount', async () => {
    const response = await request(app)
      .post('/checkout')
      .send({
        amount: -100,
        email: 'test@example.com'
      });

    expect(response.status).toBe(400);
    expect(response.body).toHaveProperty('error', 'Invalid request data');
    expect(response.body.details).toBeDefined();
  });
}); 