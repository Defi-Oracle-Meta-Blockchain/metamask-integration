#!/bin/bash

# Update Smart Accounts configuration with deployed addresses
# This script helps update config/smart-accounts-config.json after deployment

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_FILE="$PROJECT_ROOT/config/smart-accounts-config.json"

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

log_info "========================================="
log_info "Update Smart Accounts Configuration"
log_info "========================================="
log_info ""

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    log_error "jq is required but not installed. Install with: apt-get install jq"
    exit 1
fi

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    log_error "Config file not found: $CONFIG_FILE"
    exit 1
fi

# Function to update address in config
update_address() {
    local key=$1
    local address=$2
    
    if [ -z "$address" ]; then
        log_warn "Skipping $key (no address provided)"
        return
    fi
    
    # Validate address format
    if [[ ! "$address" =~ ^0x[0-9a-fA-F]{40}$ ]]; then
        log_error "Invalid address format: $address"
        return
    fi
    
    # Update config using jq
    tmp_file=$(mktemp)
    jq ".$key = \"$address\"" "$CONFIG_FILE" > "$tmp_file"
    mv "$tmp_file" "$CONFIG_FILE"
    
    log_success "Updated $key: $address"
}

# Function to update deployment info
update_deployment() {
    local contract=$1
    local address=$2
    local tx_hash=$3
    local block_number=$4
    
    if [ -z "$address" ]; then
        log_warn "Skipping deployment info for $contract (no address provided)"
        return
    fi
    
    tmp_file=$(mktemp)
    jq ".deployment.$contract.address = \"$address\"" "$CONFIG_FILE" > "$tmp_file"
    mv "$tmp_file" "$CONFIG_FILE"
    
    if [ -n "$tx_hash" ]; then
        tmp_file=$(mktemp)
        jq ".deployment.$contract.transactionHash = \"$tx_hash\"" "$CONFIG_FILE" > "$tmp_file"
        mv "$tmp_file" "$CONFIG_FILE"
    fi
    
    if [ -n "$block_number" ]; then
        tmp_file=$(mktemp)
        jq ".deployment.$contract.blockNumber = $block_number" "$CONFIG_FILE" > "$tmp_file"
        mv "$tmp_file" "$CONFIG_FILE"
    fi
    
    log_success "Updated deployment info for $contract"
}

# Interactive mode
if [ "$1" = "--interactive" ] || [ "$1" = "-i" ]; then
    log_info "Interactive mode: Enter addresses when prompted"
    log_info ""
    
    read -p "EntryPoint address (or press Enter to skip): " entry_point
    read -p "AccountFactory address (or press Enter to skip): " account_factory
    read -p "Paymaster address (or press Enter to skip): " paymaster
    
    update_address "entryPointAddress" "$entry_point"
    update_address "accountFactoryAddress" "$account_factory"
    update_address "paymasterAddress" "$paymaster"
    
    log_info ""
    log_success "Configuration updated!"
    exit 0
fi

# Command line mode
if [ $# -eq 0 ]; then
    log_info "Usage:"
    log_info "  $0 --interactive          # Interactive mode"
    log_info "  $0 --entry-point ADDRESS   # Update EntryPoint address"
    log_info "  $0 --account-factory ADDRESS # Update AccountFactory address"
    log_info "  $0 --paymaster ADDRESS    # Update Paymaster address"
    log_info "  $0 --all ENTRY_POINT ACCOUNT_FACTORY [PAYMASTER] # Update all"
    exit 0
fi

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --entry-point)
            update_address "entryPointAddress" "$2"
            shift 2
            ;;
        --account-factory)
            update_address "accountFactoryAddress" "$2"
            shift 2
            ;;
        --paymaster)
            update_address "paymasterAddress" "$2"
            shift 2
            ;;
        --all)
            update_address "entryPointAddress" "$2"
            update_address "accountFactoryAddress" "$3"
            if [ -n "$4" ]; then
                update_address "paymasterAddress" "$4"
            fi
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

log_info ""
log_success "Configuration updated!"
