#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "🚀 Testing Crypto Checkout Simulator"
echo "======================================"

# Function to check response
check_response() {
    if [ $1 -eq $2 ]; then
        echo -e "${GREEN}✓ $3${NC}"
    else
        echo -e "${RED}✗ $3${NC}"
        echo "Expected status $2, got $1"
        exit 1
    fi
}

# 1. Test Health Endpoint
echo -e "\n${BLUE}📊 Testing Health Endpoint${NC}"
HEALTH_RESPONSE=$(curl -s -w "%{http_code}" http://localhost:3000/health)
HEALTH_STATUS=${HEALTH_RESPONSE: -3}
HEALTH_BODY=${HEALTH_RESPONSE:0:${#HEALTH_RESPONSE}-3}
check_response $HEALTH_STATUS 200 "Health endpoint should return 200"
echo "Response: $HEALTH_BODY"

# 2. Test Checkout Endpoint - Success Case
echo -e "\n${BLUE}💳 Testing Checkout Endpoint - Success${NC}"
CHECKOUT_RESPONSE=$(curl -s -w "%{http_code}" -X POST http://localhost:3000/checkout \
-H "Content-Type: application/json" \
-d '{
  "amount": 100,
  "email": "test@example.com"
}')
CHECKOUT_STATUS=${CHECKOUT_RESPONSE: -3}
CHECKOUT_BODY=${CHECKOUT_RESPONSE:0:${#CHECKOUT_RESPONSE}-3}
check_response $CHECKOUT_STATUS 200 "Checkout should succeed with valid data"
echo "Response: $CHECKOUT_BODY"

# Extract transaction_id for webhook test
TRANSACTION_ID=$(echo $CHECKOUT_BODY | grep -o '"transaction_id":"[^"]*' | cut -d'"' -f4)

# 3. Test Checkout Endpoint - Error Cases
echo -e "\n${BLUE}❌ Testing Checkout Validation${NC}"

# Test negative amount
NEG_AMOUNT_RESPONSE=$(curl -s -w "%{http_code}" -X POST http://localhost:3000/checkout \
-H "Content-Type: application/json" \
-d '{
  "amount": -100,
  "email": "test@example.com"
}')
NEG_AMOUNT_STATUS=${NEG_AMOUNT_RESPONSE: -3}
check_response $NEG_AMOUNT_STATUS 400 "Should reject negative amount"

# Test invalid email
INVALID_EMAIL_RESPONSE=$(curl -s -w "%{http_code}" -X POST http://localhost:3000/checkout \
-H "Content-Type: application/json" \
-d '{
  "amount": 100,
  "email": "invalid-email"
}')
INVALID_EMAIL_STATUS=${INVALID_EMAIL_RESPONSE: -3}
check_response $INVALID_EMAIL_STATUS 400 "Should reject invalid email"

# Test missing fields
MISSING_FIELDS_RESPONSE=$(curl -s -w "%{http_code}" -X POST http://localhost:3000/checkout \
-H "Content-Type: application/json" \
-d '{}')
MISSING_FIELDS_STATUS=${MISSING_FIELDS_RESPONSE: -3}
check_response $MISSING_FIELDS_STATUS 400 "Should reject missing fields"

# 4. Test Webhook Endpoint - Success Case
echo -e "\n${BLUE}🔔 Testing Webhook Endpoint${NC}"
WEBHOOK_RESPONSE=$(curl -s -w "%{http_code}" -X POST http://localhost:3000/webhook \
-H "Content-Type: application/json" \
-d "{
  \"transaction_id\": \"$TRANSACTION_ID\",
  \"status\": \"completed\"
}")
WEBHOOK_STATUS=${WEBHOOK_RESPONSE: -3}
WEBHOOK_BODY=${WEBHOOK_RESPONSE:0:${#WEBHOOK_RESPONSE}-3}
check_response $WEBHOOK_STATUS 200 "Webhook should succeed with valid data"
echo "Response: $WEBHOOK_BODY"

# 5. Test Webhook Endpoint - Error Cases
echo -e "\n${BLUE}❌ Testing Webhook Validation${NC}"

# Test non-existent transaction
NON_EXISTENT_RESPONSE=$(curl -s -w "%{http_code}" -X POST http://localhost:3000/webhook \
-H "Content-Type: application/json" \
-d '{
  "transaction_id": "non-existent-id",
  "status": "completed"
}')
NON_EXISTENT_STATUS=${NON_EXISTENT_RESPONSE: -3}
check_response $NON_EXISTENT_STATUS 404 "Should reject non-existent transaction"

# Test invalid status
INVALID_STATUS_RESPONSE=$(curl -s -w "%{http_code}" -X POST http://localhost:3000/webhook \
-H "Content-Type: application/json" \
-d "{
  \"transaction_id\": \"$TRANSACTION_ID\",
  \"status\": \"invalid_status\"
}")
INVALID_STATUS_STATUS=${INVALID_STATUS_RESPONSE: -3}
check_response $INVALID_STATUS_STATUS 400 "Should reject invalid status"

# 6. Test Transaction List
echo -e "\n${BLUE}📋 Testing Transaction List${NC}"
TRANSACTIONS_RESPONSE=$(curl -s -w "%{http_code}" http://localhost:3000/transactions)
TRANSACTIONS_STATUS=${TRANSACTIONS_RESPONSE: -3}
TRANSACTIONS_BODY=${TRANSACTIONS_RESPONSE:0:${#TRANSACTIONS_RESPONSE}-3}
check_response $TRANSACTIONS_STATUS 200 "Transaction list should return 200"
echo "Found transactions: $(echo $TRANSACTIONS_BODY | grep -o '"id"' | wc -l)"

echo -e "\n${GREEN}✅ All tests completed successfully!${NC}"
echo -e "${BLUE}📋 Summary: Crypto checkout simulation is working perfectly${NC}" 