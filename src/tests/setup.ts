import { DataSource } from 'typeorm';
import { Transaction } from '../entities/Transaction';

export const TestDataSource = new DataSource({
  type: 'sqlite',
  database: ':memory:',
  dropSchema: true,
  entities: [Transaction],
  synchronize: true,
  logging: false
});

export const setupTestDatabase = async () => {
  if (!TestDataSource.isInitialized) {
    await TestDataSource.initialize();
  }
};

export const clearTestDatabase = async () => {
  if (TestDataSource.isInitialized) {
    const repository = TestDataSource.getRepository(Transaction);
    await repository.clear();
  }
};

export const closeTestDatabase = async () => {
  if (TestDataSource.isInitialized) {
    await TestDataSource.destroy();
  }
}; 