#!/bin/bash

# Smart Accounts Health Check Script
# Checks the health of deployed Smart Accounts infrastructure

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

log_info "Smart Accounts Health Check"
log_info "=========================="

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

HEALTH_STATUS=0

# Check RPC connectivity
log_info "1. Checking RPC connectivity..."
BLOCK_NUMBER=$(cast block-number --rpc-url "$RPC_URL_138" 2>/dev/null || echo "")
if [ -n "$BLOCK_NUMBER" ]; then
    log_success "   RPC is accessible (block: $BLOCK_NUMBER)"
else
    log_error "   RPC is not accessible"
    HEALTH_STATUS=1
fi

# Check EntryPoint
if [ -n "$ENTRY_POINT" ] && [ "$ENTRY_POINT" != "null" ] && [ "$ENTRY_POINT" != "" ]; then
    log_info "2. Checking EntryPoint contract..."
    CODE=$(cast code "$ENTRY_POINT" --rpc-url "$RPC_URL_138" 2>/dev/null || echo "")
    if [ -n "$CODE" ] && [ "$CODE" != "0x" ]; then
        BALANCE=$(cast balance "$ENTRY_POINT" --rpc-url "$RPC_URL_138" 2>/dev/null || echo "0")
        log_success "   EntryPoint is deployed (balance: $(cast --to-unit "$BALANCE" ether) ETH)"
    else
        log_error "   EntryPoint contract not found"
        HEALTH_STATUS=1
    fi
else
    log_warning "2. EntryPoint not configured"
fi

# Check AccountFactory
if [ -n "$ACCOUNT_FACTORY" ] && [ "$ACCOUNT_FACTORY" != "null" ] && [ "$ACCOUNT_FACTORY" != "" ]; then
    log_info "3. Checking AccountFactory contract..."
    CODE=$(cast code "$ACCOUNT_FACTORY" --rpc-url "$RPC_URL_138" 2>/dev/null || echo "")
    if [ -n "$CODE" ] && [ "$CODE" != "0x" ]; then
        BALANCE=$(cast balance "$ACCOUNT_FACTORY" --rpc-url "$RPC_URL_138" 2>/dev/null || echo "0")
        log_success "   AccountFactory is deployed (balance: $(cast --to-unit "$BALANCE" ether) ETH)"
    else
        log_error "   AccountFactory contract not found"
        HEALTH_STATUS=1
    fi
else
    log_warning "3. AccountFactory not configured"
fi

# Check Paymaster (optional)
if [ -n "$PAYMASTER" ] && [ "$PAYMASTER" != "null" ] && [ "$PAYMASTER" != "" ]; then
    log_info "4. Checking Paymaster contract..."
    CODE=$(cast code "$PAYMASTER" --rpc-url "$RPC_URL_138" 2>/dev/null || echo "")
    if [ -n "$CODE" ] && [ "$CODE" != "0x" ]; then
        BALANCE=$(cast balance "$PAYMASTER" --rpc-url "$RPC_URL_138" 2>/dev/null || echo "0")
        log_success "   Paymaster is deployed (balance: $(cast --to-unit "$BALANCE" ether) ETH)"
    else
        log_warning "   Paymaster contract not found (optional)"
    fi
else
    log_info "4. Paymaster not configured (optional)"
fi

# Check configuration file
log_info "5. Checking configuration file..."
if jq empty "$CONFIG_FILE" 2>/dev/null; then
    CHAIN_ID=$(jq -r '.chainId // empty' "$CONFIG_FILE")
    if [ "$CHAIN_ID" = "138" ]; then
        log_success "   Configuration file is valid (ChainID: $CHAIN_ID)"
    else
        log_warning "   Configuration file ChainID mismatch (expected: 138, found: $CHAIN_ID)"
    fi
else
    log_error "   Configuration file is invalid"
    HEALTH_STATUS=1
fi

# Check SDK installation
log_info "6. Checking SDK installation..."
if [ -d "$PROJECT_ROOT/node_modules/@metamask/smart-accounts-kit" ]; then
    log_success "   Smart Accounts Kit SDK is installed"
else
    log_warning "   Smart Accounts Kit SDK not found (run: ./scripts/install-smart-accounts-sdk.sh)"
fi

# Summary
log_info "=========================="
if [ $HEALTH_STATUS -eq 0 ]; then
    log_success "Health check passed! ✅"
    exit 0
else
    log_error "Health check failed! ❌"
    exit 1
fi
