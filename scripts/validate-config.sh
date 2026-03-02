#!/bin/bash

# Configuration Validation Script
# Validates Smart Accounts configuration files

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

log_info "Configuration Validation"
log_info "========================"

# Check if jq is available
if ! command -v jq &> /dev/null; then
    log_error "jq not found. Please install jq first."
    exit 1
fi

VALIDATION_STATUS=0

# Validate smart-accounts-config.json
CONFIG_FILE="$PROJECT_ROOT/config/smart-accounts-config.json"
log_info "1. Validating smart-accounts-config.json..."

if [ ! -f "$CONFIG_FILE" ]; then
    log_error "   Configuration file not found: $CONFIG_FILE"
    VALIDATION_STATUS=1
else
    # Check JSON validity
    if ! jq empty "$CONFIG_FILE" 2>/dev/null; then
        log_error "   Invalid JSON format"
        VALIDATION_STATUS=1
    else
        log_success "   JSON format is valid"
        
        # Check required fields
        CHAIN_ID=$(jq -r '.chainId // empty' "$CONFIG_FILE")
        if [ -z "$CHAIN_ID" ] || [ "$CHAIN_ID" = "null" ]; then
            log_error "   Missing required field: chainId"
            VALIDATION_STATUS=1
        elif [ "$CHAIN_ID" != "138" ]; then
            log_warning "   ChainID is not 138 (found: $CHAIN_ID)"
        else
            log_success "   ChainID is correct: $CHAIN_ID"
        fi
        
        RPC_URL=$(jq -r '.rpcUrl // empty' "$CONFIG_FILE")
        if [ -z "$RPC_URL" ] || [ "$RPC_URL" = "null" ]; then
            log_warning "   Missing field: rpcUrl"
        else
            log_success "   RPC URL configured: $RPC_URL"
        fi
        
        ENTRY_POINT=$(jq -r '.entryPointAddress // empty' "$CONFIG_FILE")
        if [ -z "$ENTRY_POINT" ] || [ "$ENTRY_POINT" = "null" ] || [ "$ENTRY_POINT" = "" ]; then
            log_warning "   EntryPoint address not configured"
        else
            # Validate address format
            if [[ "$ENTRY_POINT" =~ ^0x[a-fA-F0-9]{40}$ ]]; then
                log_success "   EntryPoint address format is valid: $ENTRY_POINT"
            else
                log_error "   EntryPoint address format is invalid: $ENTRY_POINT"
                VALIDATION_STATUS=1
            fi
        fi
        
        ACCOUNT_FACTORY=$(jq -r '.accountFactoryAddress // empty' "$CONFIG_FILE")
        if [ -z "$ACCOUNT_FACTORY" ] || [ "$ACCOUNT_FACTORY" = "null" ] || [ "$ACCOUNT_FACTORY" = "" ]; then
            log_warning "   AccountFactory address not configured"
        else
            # Validate address format
            if [[ "$ACCOUNT_FACTORY" =~ ^0x[a-fA-F0-9]{40}$ ]]; then
                log_success "   AccountFactory address format is valid: $ACCOUNT_FACTORY"
            else
                log_error "   AccountFactory address format is invalid: $ACCOUNT_FACTORY"
                VALIDATION_STATUS=1
            fi
        fi
        
        PAYMASTER=$(jq -r '.paymasterAddress // empty' "$CONFIG_FILE")
        if [ -n "$PAYMASTER" ] && [ "$PAYMASTER" != "null" ] && [ "$PAYMASTER" != "" ]; then
            # Validate address format
            if [[ "$PAYMASTER" =~ ^0x[a-fA-F0-9]{40}$ ]]; then
                log_success "   Paymaster address format is valid: $PAYMASTER"
            else
                log_error "   Paymaster address format is invalid: $PAYMASTER"
                VALIDATION_STATUS=1
            fi
        else
            log_info "   Paymaster not configured (optional)"
        fi
    fi
fi

# Validate monitoring-config.json
MONITORING_CONFIG="$PROJECT_ROOT/config/monitoring-config.json"
log_info "2. Validating monitoring-config.json..."

if [ ! -f "$MONITORING_CONFIG" ]; then
    log_warning "   Monitoring configuration file not found (optional)"
else
    if ! jq empty "$MONITORING_CONFIG" 2>/dev/null; then
        log_error "   Invalid JSON format"
        VALIDATION_STATUS=1
    else
        log_success "   Monitoring configuration is valid"
    fi
fi

# Validate analytics-config.json
ANALYTICS_CONFIG="$PROJECT_ROOT/config/analytics-config.json"
log_info "3. Validating analytics-config.json..."

if [ ! -f "$ANALYTICS_CONFIG" ]; then
    log_warning "   Analytics configuration file not found (optional)"
else
    if ! jq empty "$ANALYTICS_CONFIG" 2>/dev/null; then
        log_error "   Invalid JSON format"
        VALIDATION_STATUS=1
    else
        log_success "   Analytics configuration is valid"
    fi
fi

# Summary
log_info "========================"
if [ $VALIDATION_STATUS -eq 0 ]; then
    log_success "Configuration validation passed! ✅"
    exit 0
else
    log_error "Configuration validation failed! ❌"
    exit 1
fi
