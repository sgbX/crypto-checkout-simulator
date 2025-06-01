# =====================================================
# Crypto Checkout Simulator - Windows Test Script
# =====================================================
# PowerShell equivalent of test.sh for Windows users
# =====================================================

Write-Host "🚀 Testing Crypto Checkout Simulator" -ForegroundColor Blue
Write-Host "======================================" -ForegroundColor Blue

$BaseUrl = "http://localhost:3000"
$ErrorCount = 0

function Test-Response {
    param($Response, $ExpectedStatus, $TestName)
    
    if ($Response.StatusCode -eq $ExpectedStatus) {
        Write-Host "✓ $TestName" -ForegroundColor Green
    } else {
        Write-Host "✗ $TestName" -ForegroundColor Red
        Write-Host "Expected status $ExpectedStatus, got $($Response.StatusCode)" -ForegroundColor Red
        $script:ErrorCount++
    }
}

function Test-ErrorResponse {
    param($StatusCode, $ExpectedStatus, $TestName)
    
    if ($StatusCode -eq $ExpectedStatus) {
        Write-Host "✓ $TestName" -ForegroundColor Green
    } else {
        Write-Host "✗ $TestName" -ForegroundColor Red
        Write-Host "Expected status $ExpectedStatus, got $StatusCode" -ForegroundColor Red
        $script:ErrorCount++
    }
}

# Test 1: Health Endpoint
Write-Host "`n📊 Testing Health Endpoint" -ForegroundColor Blue
try {
    $HealthResponse = Invoke-WebRequest -Uri "$BaseUrl/health" -Method Get
    Test-Response $HealthResponse 200 "Health endpoint should return 200"
    Write-Host "Response: $($HealthResponse.Content)"
} catch {
    Write-Host "✗ Health endpoint failed: $($_.Exception.Message)" -ForegroundColor Red
    $ErrorCount++
}

# Test 2: Checkout Endpoint - Success Case
Write-Host "`n💳 Testing Checkout Endpoint - Success" -ForegroundColor Blue
$CheckoutBody = @{
    amount = 100
    email = "test@example.com"
} | ConvertTo-Json

try {
    $CheckoutResponse = Invoke-WebRequest -Uri "$BaseUrl/checkout" -Method Post -Body $CheckoutBody -ContentType "application/json"
    Test-Response $CheckoutResponse 200 "Checkout should succeed with valid data"
    
    $CheckoutData = $CheckoutResponse.Content | ConvertFrom-Json
    $TransactionId = $CheckoutData.transaction_id
    Write-Host "Response: $($CheckoutResponse.Content)"
    Write-Host "Transaction ID: $TransactionId" -ForegroundColor Yellow
} catch {
    Write-Host "✗ Checkout failed: $($_.Exception.Message)" -ForegroundColor Red
    $ErrorCount++
    exit 1
}

# Test 3: Checkout Validation Tests
Write-Host "`n❌ Testing Checkout Validation" -ForegroundColor Blue

# Test negative amount
$NegativeAmountBody = @{
    amount = -100
    email = "test@example.com"
} | ConvertTo-Json

try {
    Invoke-WebRequest -Uri "$BaseUrl/checkout" -Method Post -Body $NegativeAmountBody -ContentType "application/json"
    Test-ErrorResponse 200 400 "Should reject negative amount"
} catch {
    $StatusCode = $_.Exception.Response.StatusCode.value__
    Test-ErrorResponse $StatusCode 400 "Should reject negative amount"
}

# Test invalid email
$InvalidEmailBody = @{
    amount = 100
    email = "invalid-email"
} | ConvertTo-Json

try {
    Invoke-WebRequest -Uri "$BaseUrl/checkout" -Method Post -Body $InvalidEmailBody -ContentType "application/json"
    Test-ErrorResponse 200 400 "Should reject invalid email"
} catch {
    $StatusCode = $_.Exception.Response.StatusCode.value__
    Test-ErrorResponse $StatusCode 400 "Should reject invalid email"
}

# Test missing fields
$EmptyBody = @{} | ConvertTo-Json

try {
    Invoke-WebRequest -Uri "$BaseUrl/checkout" -Method Post -Body $EmptyBody -ContentType "application/json"
    Test-ErrorResponse 200 400 "Should reject missing fields"
} catch {
    $StatusCode = $_.Exception.Response.StatusCode.value__
    Test-ErrorResponse $StatusCode 400 "Should reject missing fields"
}

# Test 4: Webhook Endpoint
Write-Host "`n🔔 Testing Webhook Endpoint" -ForegroundColor Blue
$WebhookBody = @{
    transaction_id = $TransactionId
    status = "completed"
} | ConvertTo-Json

try {
    $WebhookResponse = Invoke-WebRequest -Uri "$BaseUrl/webhook" -Method Post -Body $WebhookBody -ContentType "application/json"
    Test-Response $WebhookResponse 200 "Webhook should succeed with valid data"
    Write-Host "Response: $($WebhookResponse.Content)"
} catch {
    Write-Host "✗ Webhook failed: $($_.Exception.Message)" -ForegroundColor Red
    $ErrorCount++
}

# Test 5: Webhook Validation Tests
Write-Host "`n❌ Testing Webhook Validation" -ForegroundColor Blue

# Test non-existent transaction
$NonExistentBody = @{
    transaction_id = "non-existent-id"
    status = "completed"
} | ConvertTo-Json

try {
    Invoke-WebRequest -Uri "$BaseUrl/webhook" -Method Post -Body $NonExistentBody -ContentType "application/json"
    Test-ErrorResponse 200 404 "Should reject non-existent transaction"
} catch {
    $StatusCode = $_.Exception.Response.StatusCode.value__
    Test-ErrorResponse $StatusCode 404 "Should reject non-existent transaction"
}

# Test invalid status
$InvalidStatusBody = @{
    transaction_id = $TransactionId
    status = "invalid_status"
} | ConvertTo-Json

try {
    Invoke-WebRequest -Uri "$BaseUrl/webhook" -Method Post -Body $InvalidStatusBody -ContentType "application/json"
    Test-ErrorResponse 200 400 "Should reject invalid status"
} catch {
    $StatusCode = $_.Exception.Response.StatusCode.value__
    Test-ErrorResponse $StatusCode 400 "Should reject invalid status"
}

# Test 6: Transaction List
Write-Host "`n📋 Testing Transaction List" -ForegroundColor Blue
try {
    $TransactionsResponse = Invoke-WebRequest -Uri "$BaseUrl/transactions" -Method Get
    Test-Response $TransactionsResponse 200 "Transaction list should return 200"
    
    $TransactionsData = $TransactionsResponse.Content | ConvertFrom-Json
    $TransactionCount = $TransactionsData.Count
    Write-Host "Found transactions: $TransactionCount"
} catch {
    Write-Host "✗ Transaction list failed: $($_.Exception.Message)" -ForegroundColor Red
    $ErrorCount++
}

# Final Results
Write-Host "`n" -NoNewline
if ($ErrorCount -eq 0) {
    Write-Host "✅ All tests completed successfully!" -ForegroundColor Green
    Write-Host "📋 Summary: Crypto checkout simulation is working perfectly" -ForegroundColor Blue
} else {
    Write-Host "❌ $ErrorCount test(s) failed!" -ForegroundColor Red
    exit 1
} 