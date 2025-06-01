# Crypto Checkout Simulator

A lightweight crypto checkout backend simulation built with TypeScript and Express. This simulates the Coinbase Commerce API for processing cryptocurrency payments.

## Requirements Implementation

This covers all the case study requirements:

### Core Features

1. **Checkout API** - `POST /checkout` accepting amount and email, returns fake payment URL
2. **Webhook Handler** - `POST /webhook` to update transaction status  
3. **Database** - SQLite with transaction storage
4. **Documentation** - This README with setup and usage

### Bonus Stuff

- Input validation with Zod
- Retry logic for webhooks (ran into some DB issues during development)
- Health check endpoint
- Test suite with Jest
- Logging with Winston

## Setup

```bash
git clone <repo>
cd crypto-checkout-simulator
npm install
npm run dev
```

Server runs on `http://localhost:3000`

## API

### POST /checkout
```json
{
  "amount": 100,
  "email": "test@example.com"
}
```

Returns:
```json
{
  "success": true,
  "transaction_id": "uuid",
  "status": "pending",
  "payment_url": "https://fake.coinbase.com/pay/uuid"
}
```

### POST /webhook
```json
{
  "transaction_id": "uuid",
  "status": "completed"
}
```

### GET /health
Basic health check

### GET /transactions
List all transactions

## Database

Simple transaction table:
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

## Testing

Run the test scripts:
```bash
# Linux/Mac
./test.sh

# Windows  
./test.ps1
```

Or test manually:
```bash
# Unit tests
npm test

# Manual API testing
curl -X POST http://localhost:3000/checkout \
  -H "Content-Type: application/json" \
  -d '{"amount": 100, "email": "test@example.com"}'
```

## What's Missing (Production TODOs)

- Webhook signature verification
- Rate limiting 
- Proper authentication
- Database migrations
- Error tracking (Sentry)
- Docker setup
- Real payment processing

## Architecture

```
src/
├── entities/     # TypeORM models
├── routes/       # API endpoints  
├── tests/        # Jest tests
├── app.ts        # Express setup
├── database.ts   # DB config
└── index.ts      # Entry point
```

Built with: TypeScript, Express, TypeORM, SQLite, Jest, Winston, Zod 