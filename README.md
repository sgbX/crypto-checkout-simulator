# Crypto Checkout Simulator 🚀

A robust, production-ready crypto checkout backend simulator built with TypeScript and Express. This project simulates the Coinbase Commerce API for processing cryptocurrency payments, featuring comprehensive testing, error handling, and logging.

[![TypeScript](https://img.shields.io/badge/TypeScript-5.0+-blue.svg)](https://www.typescriptlang.org/)
[![Node.js](https://img.shields.io/badge/Node.js-18+-green.svg)](https://nodejs.org/)
[![Express](https://img.shields.io/badge/Express-4.x-lightgrey.svg)](https://expressjs.com/)
[![Jest](https://img.shields.io/badge/Jest-Testing-red.svg)](https://jestjs.io/)

## 🎯 Overview

This application provides a complete backend simulation for cryptocurrency payment processing, implementing the core workflow of a payment gateway with transaction management, webhook handling, and comprehensive validation.

## ✨ Features

### Core Functionality
- **💳 Checkout API** - Create payment transactions with amount and email validation
- **🔗 Webhook Handler** - Process payment status updates with robust error handling
- **💾 Database Management** - SQLite database with TypeORM for transaction persistence
- **🔍 Transaction Queries** - Retrieve and monitor payment transactions

### Quality & Reliability
- **🛡️ Input Validation** - Comprehensive validation using Zod schemas
- **🔄 Retry Logic** - Exponential backoff for webhook processing
- **📊 Health Monitoring** - Health check endpoint for service monitoring
- **📝 Comprehensive Logging** - Winston-based logging with multiple levels
- **🧪 Full Test Coverage** - Jest test suite with unit and integration tests

## 🚀 Quick Start

### Prerequisites
- Node.js 18+ 
- npm or yarn

### Installation

```bash
# Clone the repository
git clone https://github.com/sgbX/crypto-checkout-simulator.git
cd crypto-checkout-simulator

# Install dependencies
npm install

# Build the project
npm run build

# Start development server
npm run dev
```

The server will start on `http://localhost:3000`

### Production Setup

```bash
# Build for production
npm run build

# Start production server
npm start
```

## 📚 API Documentation

### Create Checkout Session

**Endpoint:** `POST /checkout`

Create a new payment transaction and get a simulated payment URL.

**Request:**
```json
{
  "amount": 100.50,
  "email": "customer@example.com"
}
```

**Response:**
```json
{
  "success": true,
  "transaction_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "status": "pending",
  "payment_url": "https://fake.coinbase.com/pay/a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```

**Validation Rules:**
- `amount`: Must be a positive number
- `email`: Must be a valid email address

### Process Webhook

**Endpoint:** `POST /webhook`

Update transaction status based on payment gateway notifications.

**Request:**
```json
{
  "transaction_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "status": "completed"
}
```

**Response:**
```json
{
  "success": true,
  "transaction": {
    "id": "1",
    "transaction_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "email": "customer@example.com",
    "amount": "100.50",
    "status": "completed",
    "created_at": "2024-01-15T10:30:00.000Z",
    "updated_at": "2024-01-15T10:35:00.000Z"
  }
}
```

**Status Values:**
- `pending`: Initial transaction state
- `completed`: Payment successful
- `failed`: Payment failed

### Health Check

**Endpoint:** `GET /health`

Check service health and database connectivity.

**Response:**
```json
{
  "status": "ok",
  "timestamp": "2024-01-15T10:30:00.000Z",
  "database": "connected"
}
```

### List Transactions

**Endpoint:** `GET /transactions`

Retrieve all transactions for monitoring and debugging.

**Response:**
```json
{
  "transactions": [
    {
      "id": "1",
      "transaction_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "email": "customer@example.com",
      "amount": "100.50",
      "status": "completed",
      "created_at": "2024-01-15T10:30:00.000Z",
      "updated_at": "2024-01-15T10:35:00.000Z"
    }
  ]
}
```

## 🗄️ Database Schema

The application uses SQLite with TypeORM for data persistence.

### Transaction Table

```sql
CREATE TABLE "transaction" (
  "id" varchar PRIMARY KEY,
  "email" varchar NOT NULL,
  "amount" decimal(10,2) NOT NULL,
  "status" varchar NOT NULL DEFAULT 'pending',
  "transaction_id" varchar UNIQUE NOT NULL,
  "created_at" datetime NOT NULL DEFAULT (datetime('now')),
  "updated_at" datetime NOT NULL DEFAULT (datetime('now'))
);
```

**Indexes:**
- Primary key on `id`
- Unique constraint on `transaction_id`
- Index on `status` for efficient queries

## 🧪 Testing

### Automated Testing

```bash
# Run all tests
npm test

# Run tests with coverage
npm run test:coverage

# Run tests in watch mode
npm run test:watch
```

### Integration Testing Scripts

**For Linux/macOS:**
```bash
./test.sh
```

**For Windows PowerShell:**
```bash
./test.ps1
```

### Manual API Testing

```bash
# Start the server
npm run dev

# Test checkout endpoint
curl -X POST http://localhost:3000/checkout \
  -H "Content-Type: application/json" \
  -d '{"amount": 100, "email": "test@example.com"}'

# Test webhook endpoint (replace transaction_id with actual value)
curl -X POST http://localhost:3000/webhook \
  -H "Content-Type: application/json" \
  -d '{"transaction_id": "YOUR_TRANSACTION_ID", "status": "completed"}'

# Check health
curl http://localhost:3000/health

# List transactions
curl http://localhost:3000/transactions
```

## 🏗️ Architecture

```
src/
├── entities/           # TypeORM entity definitions
│   └── Transaction.ts  # Transaction model
├── routes/            # Express route handlers
│   ├── checkout.ts    # Payment creation logic
│   ├── webhook.ts     # Webhook processing
│   ├── health.ts      # Health check endpoint
│   └── transactions.ts # Transaction queries
├── tests/             # Test suites
│   ├── checkout.test.ts
│   ├── webhook.test.ts
│   └── setup.ts       # Test configuration
├── app.ts             # Express application setup
├── database.ts        # Database configuration
└── index.ts           # Application entry point
```

## 🛠️ Technology Stack

- **Runtime:** Node.js 18+
- **Language:** TypeScript 5.0+
- **Framework:** Express.js 4.x
- **Database:** SQLite with TypeORM
- **Validation:** Zod
- **Testing:** Jest with Supertest
- **Logging:** Winston
- **Process Management:** Built-in Node.js

## 📋 Scripts

```json
{
  "dev": "ts-node src/index.ts",
  "build": "tsc",
  "start": "node dist/index.js",
  "test": "jest",
  "test:watch": "jest --watch",
  "test:coverage": "jest --coverage"
}
```

## 🔧 Configuration

### Environment Variables

Create a `.env` file for configuration (optional):

```env
PORT=3000
NODE_ENV=development
DATABASE_PATH=./database.sqlite
LOG_LEVEL=info
```

### TypeScript Configuration

The project uses strict TypeScript configuration with:
- Strict type checking
- ES2020 target
- CommonJS modules
- Source maps enabled
- Declaration files generated

## 🚧 Production Considerations

### Security Enhancements Needed
- **Webhook Signature Verification** - Validate webhook authenticity
- **Rate Limiting** - Prevent API abuse
- **Authentication & Authorization** - Secure API endpoints
- **HTTPS Enforcement** - Secure data transmission
- **Input Sanitization** - Additional XSS protection

### Scalability Improvements
- **Database Migration System** - Version controlled schema changes
- **Connection Pooling** - Optimize database connections
- **Caching Layer** - Redis for frequently accessed data
- **Load Balancing** - Horizontal scaling support
- **Message Queues** - Asynchronous webhook processing

### Monitoring & Observability
- **Error Tracking** - Sentry or similar service
- **Metrics Collection** - Prometheus/Grafana
- **Distributed Tracing** - Jaeger or Zipkin
- **Performance Monitoring** - APM tools

### DevOps & Deployment
- **Docker Containerization** - Consistent deployment
- **CI/CD Pipeline** - Automated testing and deployment
- **Infrastructure as Code** - Terraform or similar
- **Database Backups** - Automated backup strategy

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙋‍♂️ Support

If you have any questions or need help with the project:

- Create an issue on GitHub
- Check the existing documentation
- Review the test files for usage examples

---

Built with ❤️ using TypeScript and Express.js 