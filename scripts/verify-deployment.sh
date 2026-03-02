#!/bin/bash

# Smart Accounts Deployment Verification Script
# Verifies that all contracts are deployed and configured correctly

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

log_info "Smart Accounts Deployment Verification"
log_info "======================================"

# Check if cast is available
if ! command -v cast &> /dev/null; then
    log_error "cast (Foundry) not found. Please install Foundry first."
    exit 1
fi

# Load environment variables
if [ ! -f "$SMOM_DIR/.env" ]; then
    log_error ".env file not found in $SMOM_DIR"
    exit 1
fi

source "$SMOM_DIR/.env"

if [ -z "$RPC_URL_138" ]; then
    log_error "RPC_URL_138 not set in .env"
    exit 1
fi

# Load configuration
CONFIG_FILE="$PROJECT_ROOT/config/smart-accounts-config.json"
if [ ! -f "$CONFIG_FILE" ]; then
    log_error "Configuration file not found: $CONFIG_FILE"
    exit 1
fi

# Check if jq is available
if ! command -v jq &> /dev/null; then
    log_error "jq not found. Please install jq first."
    exit 1
fi

# Extract addresses from config
ENTRY_POINT=$(jq -r '.entryPointAddress // empty' "$CONFIG_FILE")
ACCOUNT_FACTORY=$(jq -r '.accountFactoryAddress // empty' "$CONFIG_FILE")
PAYMASTER=$(jq -r '.paymasterAddress // empty' "$CONFIG_FILE")

log_info "Verifying contracts on ChainID 138..."
log_info "RPC URL: $RPC_URL_138"

# Verify EntryPoint
if [ -n "$ENTRY_POINT" ] && [ "$ENTRY_POINT" != "null" ] && [ "$ENTRY_POINT" != "" ]; then
    log_info "Checking EntryPoint at $ENTRY_POINT..."
    CODE=$(cast code "$ENTRY_POINT" --rpc-url "$RPC_URL_138" 2>/dev/null || echo "")
    if [ -n "$CODE" ] && [ "$CODE" != "0x" ]; then
        log_success "EntryPoint contract verified (has code)"
    else
        log_error "EntryPoint contract not found or has no code"
    fi
else
    log_warning "EntryPoint address not configured"
fi

# Verify AccountFactory
if [ -n "$ACCOUNT_FACTORY" ] && [ "$ACCOUNT_FACTORY" != "null" ] && [ "$ACCOUNT_FACTORY" != "" ]; then
    log_info "Checking AccountFactory at $ACCOUNT_FACTORY..."
    CODE=$(cast code "$ACCOUNT_FACTORY" --rpc-url "$RPC_URL_138" 2>/dev/null || echo "")
    if [ -n "$CODE" ] && [ "$CODE" != "0x" ]; then
        log_success "AccountFactory contract verified (has code)"
    else
        log_error "AccountFactory contract not found or has no code"
    fi
else
    log_warning "AccountFactory address not configured"
fi

# Verify Paymaster (optional)
if [ -n "$PAYMASTER" ] && [ "$PAYMASTER" != "null" ] && [ "$PAYMASTER" != "" ]; then
    log_info "Checking Paymaster at $PAYMASTER..."
    CODE=$(cast code "$PAYMASTER" --rpc-url "$RPC_URL_138" 2>/dev/null || echo "")
    if [ -n "$CODE" ] && [ "$CODE" != "0x" ]; then
        log_success "Paymaster contract verified (has code)"
    else
        log_warning "Paymaster contract not found or has no code (optional)"
    fi
else
    log_info "Paymaster not configured (optional)"
fi

# Check RPC connectivity
log_info "Checking RPC connectivity..."
BLOCK_NUMBER=$(cast block-number --rpc-url "$RPC_URL_138" 2>/dev/null || echo "")
if [ -n "$BLOCK_NUMBER" ]; then
    log_success "RPC connection successful (block: $BLOCK_NUMBER)"
else
    log_error "RPC connection failed"
    exit 1
fi

# Check configuration file
log_info "Verifying configuration file..."
if jq empty "$CONFIG_FILE" 2>/dev/null; then
    log_success "Configuration file is valid JSON"
else
    log_error "Configuration file is invalid JSON"
    exit 1
fi

# Summary
log_info "======================================"
log_info "Verification Summary:"
log_info "- RPC Connection: ✅"
log_info "- Configuration File: ✅"
if [ -n "$ENTRY_POINT" ] && [ "$ENTRY_POINT" != "null" ] && [ "$ENTRY_POINT" != "" ]; then
    log_info "- EntryPoint: ✅ Configured"
else
    log_info "- EntryPoint: ⚠️  Not configured"
fi
if [ -n "$ACCOUNT_FACTORY" ] && [ "$ACCOUNT_FACTORY" != "null" ] && [ "$ACCOUNT_FACTORY" != "" ]; then
    log_info "- AccountFactory: ✅ Configured"
else
    log_info "- AccountFactory: ⚠️  Not configured"
fi
if [ -n "$PAYMASTER" ] && [ "$PAYMASTER" != "null" ] && [ "$PAYMASTER" != "" ]; then
    log_info "- Paymaster: ✅ Configured (optional)"
else
    log_info "- Paymaster: ⚠️  Not configured (optional)"
fi

log_success "Verification complete!"
