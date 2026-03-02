#!/bin/bash

# Test MetaMask Portfolio Integration
# This script tests Blockscout API endpoints required for MetaMask Portfolio

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

EXPLORER_URL="${EXPLORER_URL:-https://explorer.d-bis.org}"
TEST_ADDRESS="${TEST_ADDRESS:-0x4207aA9aC89B8bF4795dbAbBbE17fdd224E7947C}"
CUSDT_ADDRESS="0x93E66202A11B1772E55407B32B44e5Cd8eda7f22"
CUSDC_ADDRESS="0xf22258f57794CC8E06237084b353Ab30fFfa640b"

log_info "========================================="
log_info "MetaMask Portfolio Integration Test"
log_info "========================================="
log_info ""
log_info "Explorer URL: $EXPLORER_URL"
log_info "Test Address: $TEST_ADDRESS"
log_info ""

# Test CORS headers
log_info "Testing CORS headers..."
CORS_TEST=$(curl -s -I -X OPTIONS "$EXPLORER_URL/api/v2/tokens/$CUSDT_ADDRESS" \
  -H "Origin: https://portfolio.metamask.io" \
  -H "Access-Control-Request-Method: GET" 2>&1)

if echo "$CORS_TEST" | grep -q "Access-Control-Allow-Origin"; then
    log_success "CORS headers present"
    echo "$CORS_TEST" | grep -i "access-control" | head -5
else
    log_warn "CORS headers not found or incomplete"
    echo "$CORS_TEST" | head -10
fi

log_info ""

# Test token metadata API
log_info "Testing token metadata API endpoints..."

# Test cUSDT metadata
log_info "1. Testing cUSDT metadata..."
TOKEN_METADATA=$(curl -s "$EXPLORER_URL/api/v2/tokens/$CUSDT_ADDRESS" 2>&1 || echo "ERROR")

if echo "$TOKEN_METADATA" | grep -q "symbol\|name\|decimals"; then
    log_success "cUSDT metadata API working"
    echo "$TOKEN_METADATA" | jq -r '.symbol, .name, .decimals' 2>/dev/null || echo "$TOKEN_METADATA" | head -5
else
    log_error "cUSDT metadata API failed"
    echo "$TOKEN_METADATA" | head -5
fi

log_info ""

# Test cUSDC metadata
log_info "2. Testing cUSDC metadata..."
TOKEN_METADATA=$(curl -s "$EXPLORER_URL/api/v2/tokens/$CUSDC_ADDRESS" 2>&1 || echo "ERROR")

if echo "$TOKEN_METADATA" | grep -q "symbol\|name\|decimals"; then
    log_success "cUSDC metadata API working"
    echo "$TOKEN_METADATA" | jq -r '.symbol, .name, .decimals' 2>/dev/null || echo "$TOKEN_METADATA" | head -5
else
    log_error "cUSDC metadata API failed"
    echo "$TOKEN_METADATA" | head -5
fi

log_info ""

# Test account token balances
log_info "3. Testing account token balances..."
BALANCES=$(curl -s "$EXPLORER_URL/api/v2/addresses/$TEST_ADDRESS/token-balances" 2>&1 || echo "ERROR")

if echo "$BALANCES" | grep -q "token\|balance"; then
    log_success "Token balances API working"
    echo "$BALANCES" | jq -r '.[] | "\(.token.symbol): \(.value)"' 2>/dev/null | head -5 || echo "$BALANCES" | head -5
else
    log_warn "Token balances API may not be available"
    echo "$BALANCES" | head -5
fi

log_info ""

# Test account transactions
log_info "4. Testing account transactions API..."
TXS=$(curl -s "$EXPLORER_URL/api/v2/addresses/$TEST_ADDRESS/transactions" 2>&1 || echo "ERROR")

if echo "$TXS" | grep -q "hash\|block_number"; then
    log_success "Transactions API working"
    TX_COUNT=$(echo "$TXS" | jq '.items | length' 2>/dev/null || echo "0")
    log_info "Found $TX_COUNT transactions"
else
    log_warn "Transactions API may not be available"
    echo "$TXS" | head -5
fi

log_info ""

# Test logo URLs
log_info "5. Testing token logo URLs..."
LOGO_URLS=(
    "$EXPLORER_URL/images/tokens/$CUSDT_ADDRESS.png"
    "$EXPLORER_URL/images/tokens/$CUSDC_ADDRESS.png"
)

for logo_url in "${LOGO_URLS[@]}"; do
    LOGO_TEST=$(curl -s -I "$logo_url" 2>&1 | head -1)
    if echo "$LOGO_TEST" | grep -q "200\|OK"; then
        log_success "Logo accessible: $(basename $logo_url)"
    else
        log_warn "Logo not found: $(basename $logo_url)"
    fi
done

log_info ""

# Create test report
REPORT_FILE="$PROJECT_ROOT/portfolio-integration-test-report.md"
cat > "$REPORT_FILE" << EOF
# MetaMask Portfolio Integration Test Report

**Date**: $(date)
**Explorer URL**: $EXPLORER_URL
**Test Address**: $TEST_ADDRESS

## Test Results

### CORS Configuration
- Status: $(echo "$CORS_TEST" | grep -q "Access-Control-Allow-Origin" && echo "✅ PASS" || echo "❌ FAIL")
- Headers: $(echo "$CORS_TEST" | grep -i "access-control" | head -3 | tr '\n' ' ')

### API Endpoints

1. **Token Metadata API**
   - cUSDT: $(echo "$TOKEN_METADATA" | grep -q "symbol" && echo "✅ Working" || echo "❌ Failed")
   - cUSDC: $(echo "$TOKEN_METADATA" | grep -q "symbol" && echo "✅ Working" || echo "❌ Failed")

2. **Token Balances API**
   - Status: $(echo "$BALANCES" | grep -q "token\|balance" && echo "✅ Working" || echo "⚠️ Limited")

3. **Transactions API**
   - Status: $(echo "$TXS" | grep -q "hash" && echo "✅ Working" || echo "⚠️ Limited")

4. **Logo URLs**
   - cUSDT Logo: $(curl -s -I "$EXPLORER_URL/images/tokens/$CUSDT_ADDRESS.png" 2>&1 | grep -q "200" && echo "✅ Accessible" || echo "❌ Not Found")
   - cUSDC Logo: $(curl -s -I "$EXPLORER_URL/images/tokens/$CUSDC_ADDRESS.png" 2>&1 | grep -q "200" && echo "✅ Accessible" || echo "❌ Not Found")

## Recommendations

1. Ensure all API endpoints are accessible
2. Verify CORS headers are correctly configured
3. Test from MetaMask Portfolio after deployment
4. Monitor API response times
5. Verify token logos are accessible

## Next Steps

1. Deploy Blockscout with CORS configuration
2. Test from MetaMask Portfolio
3. Verify token auto-detection
4. Verify balance display
5. Verify transaction history
EOF

log_success "Created test report: $REPORT_FILE"

log_info ""
log_info "========================================="
log_info "Portfolio Integration Test Complete!"
log_info "========================================="
log_info ""
log_info "Test report saved to: $REPORT_FILE"
log_info ""
log_info "Next steps:"
log_info "1. Review test report"
log_info "2. Fix any failing tests"
log_info "3. Test from MetaMask Portfolio"
log_info ""
