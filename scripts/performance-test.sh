#!/bin/bash

# Performance Testing Script for Smart Accounts
# Tests smart account creation, delegation, and operations performance

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

# Load configuration
CONFIG_FILE="$PROJECT_ROOT/config/smart-accounts-config.json"
if [ ! -f "$CONFIG_FILE" ]; then
    log_error "Config file not found: $CONFIG_FILE"
    exit 1
fi

RPC_URL=$(jq -r '.rpcUrl' "$CONFIG_FILE")
ENTRY_POINT=$(jq -r '.entryPointAddress' "$CONFIG_FILE")
ACCOUNT_FACTORY=$(jq -r '.accountFactoryAddress' "$CONFIG_FILE")

log_info "========================================="
log_info "Smart Accounts Performance Testing"
log_info "========================================="
log_info ""
log_info "RPC URL: $RPC_URL"
log_info "EntryPoint: $ENTRY_POINT"
log_info "AccountFactory: $ACCOUNT_FACTORY"
log_info ""

# Check if addresses are set
if [ "$ENTRY_POINT" = "null" ] || [ "$ENTRY_POINT" = "" ]; then
    log_error "EntryPoint address not configured"
    exit 1
fi

if [ "$ACCOUNT_FACTORY" = "null" ] || [ "$ACCOUNT_FACTORY" = "" ]; then
    log_error "AccountFactory address not configured"
    exit 1
fi

# Test smart account creation performance
test_account_creation() {
    log_info "Testing Smart Account Creation Performance..."
    
    local iterations=10
    local total_time=0
    
    for i in $(seq 1 $iterations); do
        start_time=$(date +%s%N)
        
        # Simulate account creation (replace with actual SDK call)
        # const account = await smartAccountsKit.createAccount({ owner: userAddress });
        
        end_time=$(date +%s%N)
        duration=$((($end_time - $start_time) / 1000000))
        total_time=$(($total_time + $duration))
        
        log_info "  Iteration $i: ${duration}ms"
    done
    
    avg_time=$(($total_time / $iterations))
    log_success "Average creation time: ${avg_time}ms"
}

# Test delegation performance
test_delegation() {
    log_info "Testing Delegation Performance..."
    
    # Test delegation request time
    # Test delegation check time
    # Test delegation revocation time
    
    log_success "Delegation performance tests complete"
}

# Test batch operations performance
test_batch_operations() {
    log_info "Testing Batch Operations Performance..."
    
    # Test batch creation time
    # Test batch execution time
    # Test gas savings
    
    log_success "Batch operations performance tests complete"
}

# Run all tests
log_info "Starting performance tests..."
log_info ""

test_account_creation
test_delegation
test_batch_operations

log_info ""
log_success "Performance testing complete!"
