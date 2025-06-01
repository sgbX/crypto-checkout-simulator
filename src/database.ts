import { DataSource } from 'typeorm';
import { Transaction } from './entities/Transaction';

export const AppDataSource = new DataSource({
  type: 'sqlite',
  database: 'database.sqlite',
  synchronize: true,
  logging: false,
  entities: [Transaction]
});

export { TestDataSource } from './tests/setup';

export async function setupDatabase() {
  try {
    await AppDataSource.initialize();
    console.log('Database connection initialized');
  } catch (error) {
    console.error('Error during database initialization:', error);
    throw error;
  }
} 