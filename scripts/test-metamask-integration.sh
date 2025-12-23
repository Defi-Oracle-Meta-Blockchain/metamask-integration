#!/usr/bin/env bash
# End-to-end MetaMask integration test script
# Tests network, RPC, tokens, and price feeds

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

RPC_URL="${RPC_URL:-https://rpc-core.d-bis.org}"
CHAIN_ID=138

# Contract addresses
ORACLE_PROXY="0x3304b747e565a97ec8ac220b0b6a1f6ffdb837e6"
WETH9="0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"
WETH10="0xf4BB2e28688e89fCcE3c0580D37d36A7672E8A9f"

log_info "========================================="
log_info "MetaMask Integration Test"
log_info "========================================="
log_info ""
log_info "RPC URL: $RPC_URL"
log_info "Chain ID: $CHAIN_ID"
log_info ""

PASSED=0
FAILED=0

test_rpc_connection() {
    log_info "Test 1: RPC Connection"
    if cast block-number --rpc-url "$RPC_URL" &>/dev/null; then
        BLOCK=$(cast block-number --rpc-url "$RPC_URL" 2>/dev/null)
        log_success "RPC connected - Block: $BLOCK"
        ((PASSED++))
        return 0
    else
        log_error "RPC connection failed"
        ((FAILED++))
        return 1
    fi
}

test_chain_id() {
    log_info "Test 2: Chain ID"
    ACTUAL_CHAIN_ID=$(cast chain-id --rpc-url "$RPC_URL" 2>/dev/null || echo "0")
    if [ "$ACTUAL_CHAIN_ID" = "$CHAIN_ID" ]; then
        log_success "Chain ID correct: $CHAIN_ID"
        ((PASSED++))
        return 0
    else
        log_error "Chain ID mismatch - Expected: $CHAIN_ID, Got: $ACTUAL_CHAIN_ID"
        ((FAILED++))
        return 1
    fi
}

test_weth9_contract() {
    log_info "Test 3: WETH9 Contract"
    if cast code "$WETH9" --rpc-url "$RPC_URL" 2>/dev/null | grep -q "0x"; then
        SUPPLY=$(cast call "$WETH9" "totalSupply()" --rpc-url "$RPC_URL" 2>/dev/null | xargs -I {} cast --to-unit {} ether 2>/dev/null || echo "0")
        log_success "WETH9 contract exists - Total Supply: $SUPPLY WETH"
        ((PASSED++))
        return 0
    else
        log_error "WETH9 contract not found"
        ((FAILED++))
        return 1
    fi
}

test_weth10_contract() {
    log_info "Test 4: WETH10 Contract"
    if cast code "$WETH10" --rpc-url "$RPC_URL" 2>/dev/null | grep -q "0x"; then
        log_success "WETH10 contract exists"
        ((PASSED++))
        return 0
    else
        log_error "WETH10 contract not found"
        ((FAILED++))
        return 1
    fi
}

test_oracle_contract() {
    log_info "Test 5: Oracle Contract"
    if cast code "$ORACLE_PROXY" --rpc-url "$RPC_URL" 2>/dev/null | grep -q "0x"; then
        # Try to get price data
        PRICE_DATA=$(cast call "$ORACLE_PROXY" "latestRoundData()" --rpc-url "$RPC_URL" 2>/dev/null || echo "")
        if [ -n "$PRICE_DATA" ] && [ "$PRICE_DATA" != "0x" ]; then
            log_success "Oracle contract exists and responds"
            ((PASSED++))
            return 0
        else
            log_warn "Oracle contract exists but may not be updating"
            ((PASSED++))
            return 0
        fi
    else
        log_error "Oracle contract not found"
        ((FAILED++))
        return 1
    fi
}

test_token_list_json() {
    log_info "Test 6: Token List JSON"
    TOKEN_LIST="$PROJECT_ROOT/docs/METAMASK_TOKEN_LIST.json"
    if [ -f "$TOKEN_LIST" ]; then
        if jq empty "$TOKEN_LIST" 2>/dev/null; then
            TOKEN_COUNT=$(jq '.tokens | length' "$TOKEN_LIST" 2>/dev/null || echo "0")
            log_success "Token list JSON valid - $TOKEN_COUNT tokens"
            ((PASSED++))
            return 0
        else
            log_error "Token list JSON is invalid"
            ((FAILED++))
            return 1
        fi
    else
        log_error "Token list JSON not found"
        ((FAILED++))
        return 1
    fi
}

test_network_config() {
    log_info "Test 7: Network Configuration"
    NETWORK_CONFIG="$PROJECT_ROOT/docs/METAMASK_NETWORK_CONFIG.json"
    if [ -f "$NETWORK_CONFIG" ]; then
        if jq empty "$NETWORK_CONFIG" 2>/dev/null; then
            CONFIG_CHAIN_ID=$(jq -r '.chainId' "$NETWORK_CONFIG" 2>/dev/null | sed 's/0x//' | xargs -I {} echo "ibase=16; {}" | bc 2>/dev/null || echo "0")
            if [ "$CONFIG_CHAIN_ID" = "$CHAIN_ID" ]; then
                log_success "Network config valid - Chain ID: $CHAIN_ID"
                ((PASSED++))
                return 0
            else
                log_error "Network config Chain ID mismatch"
                ((FAILED++))
                return 1
            fi
        else
            log_error "Network config JSON is invalid"
            ((FAILED++))
            return 1
        fi
    else
        log_error "Network config JSON not found"
        ((FAILED++))
        return 1
    fi
}

# Run all tests
test_rpc_connection
test_chain_id
test_weth9_contract
test_weth10_contract
test_oracle_contract
test_token_list_json
test_network_config

# Summary
log_info ""
log_info "========================================="
log_info "Test Summary"
log_info "========================================="
log_info "Passed: $PASSED"
if [ $FAILED -gt 0 ]; then
    log_error "Failed: $FAILED"
    exit 1
else
    log_success "Failed: $FAILED"
    log_success "All tests passed!"
    exit 0
fi

