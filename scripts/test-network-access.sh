#!/bin/bash

# Network Access Test Script
# Tests connectivity to ChainID 138 RPC endpoints

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SMOM_DIR="$(cd "$PROJECT_ROOT/../smom-dbis-138" && pwd)"

log_info "Network Access Test for ChainID 138"
log_info "===================================="

# Check if cast is available
if ! command -v cast &> /dev/null; then
    log_error "cast (Foundry) not found. Please install Foundry first."
    exit 1
fi

# Check if curl is available
if ! command -v curl &> /dev/null; then
    log_warning "curl not found. Some tests may be skipped."
fi

# Load environment variables
if [ ! -f "$SMOM_DIR/.env" ]; then
    log_error ".env file not found in $SMOM_DIR"
    exit 1
fi

source "$SMOM_DIR/.env"

# RPC endpoints to test
RPC_ENDPOINTS=(
    "${RPC_URL_138:-http://192.168.11.211:8545}"
    "http://192.168.11.211:8545"
    "http://192.168.11.250:8545"
    "https://rpc.d-bis.org"
    "https://rpc-http-pub.d-bis.org"
    "https://rpc-http-prv.d-bis.org"
)

# Remove duplicates
RPC_ENDPOINTS=($(printf '%s\n' "${RPC_ENDPOINTS[@]}" | sort -u))

# Test function
test_rpc_endpoint() {
    local rpc_url=$1
    local endpoint_name=$2
    
    log_info "Testing: $endpoint_name ($rpc_url)"
    
    # Test 1: Basic connectivity with curl
    if command -v curl &> /dev/null; then
        local response=$(curl -s -X POST "$rpc_url" \
            -H "Content-Type: application/json" \
            -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
            --max-time 5 2>&1)
        
        if echo "$response" | grep -q "result"; then
            log_success "  ✓ Basic connectivity: OK"
        else
            log_error "  ✗ Basic connectivity: FAILED"
            log_warning "  Response: $response"
            return 1
        fi
    fi
    
    # Test 2: Block number with cast
    local block_number=$(cast block-number --rpc-url "$rpc_url" 2>/dev/null || echo "")
    if [ -n "$block_number" ] && [ "$block_number" != "0" ]; then
        log_success "  ✓ Block number: $block_number"
    else
        log_error "  ✗ Block number: FAILED or network not producing blocks"
        return 1
    fi
    
    # Test 3: Chain ID
    local chain_id=$(cast chain-id --rpc-url "$rpc_url" 2>/dev/null || echo "")
    if [ "$chain_id" = "138" ]; then
        log_success "  ✓ Chain ID: $chain_id (correct)"
    elif [ -n "$chain_id" ]; then
        log_warning "  ⚠ Chain ID: $chain_id (expected 138)"
    else
        log_error "  ✗ Chain ID: FAILED"
        return 1
    fi
    
    # Test 4: Deployer balance (if available)
    if [ -n "$PRIVATE_KEY" ]; then
        local deployer=$(cast wallet address "$PRIVATE_KEY" 2>/dev/null || echo "")
        if [ -n "$deployer" ]; then
            local balance=$(cast balance "$deployer" --rpc-url "$rpc_url" 2>/dev/null || echo "0")
            local balance_eth=$(cast --to-unit "$balance" ether 2>/dev/null || echo "0")
            if [ "$balance" != "0" ]; then
                log_success "  ✓ Deployer balance: $balance_eth ETH"
            else
                log_warning "  ⚠ Deployer balance: 0 ETH (may need funding)"
            fi
        fi
    fi
    
    return 0
}

# Test all endpoints
log_info "Testing RPC endpoints..."
echo ""

WORKING_ENDPOINTS=()
FAILED_ENDPOINTS=()

for endpoint in "${RPC_ENDPOINTS[@]}"; do
    # Extract endpoint name
    endpoint_name=$(echo "$endpoint" | sed 's|https\?://||' | sed 's|:.*||')
    
    if test_rpc_endpoint "$endpoint" "$endpoint_name"; then
        WORKING_ENDPOINTS+=("$endpoint")
        log_success "✓ $endpoint_name is accessible and working"
    else
        FAILED_ENDPOINTS+=("$endpoint")
        log_error "✗ $endpoint_name is not accessible or not working"
    fi
    echo ""
done

# Summary
log_info "===================================="
log_info "Test Summary"
log_info "===================================="

if [ ${#WORKING_ENDPOINTS[@]} -gt 0 ]; then
    log_success "Working Endpoints (${#WORKING_ENDPOINTS[@]}):"
    for endpoint in "${WORKING_ENDPOINTS[@]}"; do
        log_success "  ✓ $endpoint"
    done
    echo ""
    
    # Recommend best endpoint
    if [ -n "$RPC_URL_138" ] && [[ " ${WORKING_ENDPOINTS[@]} " =~ " ${RPC_URL_138} " ]]; then
        log_success "Recommended: $RPC_URL_138 (already configured)"
    else
        log_info "Recommended: ${WORKING_ENDPOINTS[0]}"
        log_warning "Update .env: RPC_URL_138=${WORKING_ENDPOINTS[0]}"
    fi
else
    log_error "No working RPC endpoints found!"
    log_error ""
    log_error "Possible issues:"
    log_error "  1. Network connectivity problems"
    log_error "  2. RPC endpoints not operational"
    log_error "  3. Firewall blocking access"
    log_error "  4. VPN or network routing needed"
    exit 1
fi

if [ ${#FAILED_ENDPOINTS[@]} -gt 0 ]; then
    echo ""
    log_warning "Failed Endpoints (${#FAILED_ENDPOINTS[@]}):"
    for endpoint in "${FAILED_ENDPOINTS[@]}"; do
        log_warning "  ✗ $endpoint"
    done
fi

echo ""
log_success "Network access test complete!"
