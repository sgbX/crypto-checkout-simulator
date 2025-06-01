-- =====================================================
-- Crypto Checkout Simulator Database Schema
-- =====================================================


CREATE TABLE IF NOT EXISTS "transaction" (
  -- Primary key
  "id" varchar PRIMARY KEY,
  
  -- User information
  "email" varchar NOT NULL,
  
  -- Payment details
  "amount" decimal(10,2) NOT NULL CHECK (amount > 0),
  
  -- Transaction status: pending, completed, failed
  "status" varchar NOT NULL DEFAULT 'pending' 
    CHECK (status IN ('pending', 'completed', 'failed')),
  
  -- Unique transaction identifier for Coinbase integration
  "transaction_id" varchar UNIQUE NOT NULL,
  
  -- Timestamps
  "created_at" datetime NOT NULL DEFAULT (datetime('now')),
  "updated_at" datetime NOT NULL DEFAULT (datetime('now'))
);

-- =====================================================
-- Indexes for Performance
-- =====================================================

-- Index on transaction_id for webhook lookups
CREATE INDEX IF NOT EXISTS "idx_transaction_id" 
ON "transaction" ("transaction_id");

-- Index on email for user queries
CREATE INDEX IF NOT EXISTS "idx_email" 
ON "transaction" ("email");

-- Index on status for filtering
CREATE INDEX IF NOT EXISTS "idx_status" 
ON "transaction" ("status");

-- Composite index for status + created_at for reporting
CREATE INDEX IF NOT EXISTS "idx_status_created" 
ON "transaction" ("status", "created_at");

-- =====================================================
-- Sample Data (for testing)
-- =====================================================

INSERT OR IGNORE INTO "transaction" 
  ("id", "email", "amount", "status", "transaction_id", "created_at", "updated_at")
VALUES 
  ('sample-1', 'john@example.com', 99.99, 'completed', 'tx-12345', datetime('now'), datetime('now')),
  ('sample-2', 'jane@example.com', 149.50, 'pending', 'tx-67890', datetime('now'), datetime('now')),
  ('sample-3', 'bob@example.com', 75.00, 'failed', 'tx-abcde', datetime('now'), datetime('now'));

-- =====================================================
-- Views for Reporting (Production Enhancement)
-- =====================================================

-- Daily transaction summary
CREATE VIEW IF NOT EXISTS "daily_transaction_summary" AS
SELECT 
  DATE(created_at) as transaction_date,
  status,
  COUNT(*) as transaction_count,
  SUM(amount) as total_amount,
  AVG(amount) as avg_amount
FROM "transaction"
GROUP BY DATE(created_at), status
ORDER BY transaction_date DESC, status;

-- Recent transactions (last 24 hours)
CREATE VIEW IF NOT EXISTS "recent_transactions" AS
SELECT *
FROM "transaction"
WHERE created_at >= datetime('now', '-1 day')
ORDER BY created_at DESC;

-- =====================================================
-- Production Considerations
-- =====================================================

-- In production, this schema would be enhanced with:
-- 
-- 1. Additional fields:
--    - payment_method (bitcoin, ethereum, etc.)
--    - currency_code (USD, EUR, etc.)
--    - exchange_rate (for crypto conversion)
--    - coinbase_charge_id (actual Coinbase Commerce ID)
--    - webhook_signature (for verification)
--    - retry_count (for webhook retry tracking)
--    - user_ip (for fraud detection)
--    - user_agent (for analytics)
--
-- 2. Additional tables:
--    - users (normalized user data)
--    - payment_methods (supported cryptocurrencies)
--    - webhook_events (audit trail)
--    - transaction_logs (detailed activity log)
--
-- 3. Database features:
--    - Foreign key constraints
--    - Triggers for automatic updated_at
--    - Stored procedures for complex operations
--    - Partitioning for large datasets
--
-- 4. Security:
--    - Encrypted sensitive fields
--    - Row-level security
--    - Audit logging
--    - Data retention policies 