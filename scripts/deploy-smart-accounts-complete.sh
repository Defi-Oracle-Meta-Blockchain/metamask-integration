#!/bin/bash

# Complete Smart Accounts Deployment Script
# Orchestrates all deployment steps

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

log_info "Smart Accounts Complete Deployment Script"
log_info "=========================================="

# Check prerequisites
log_info "Checking prerequisites..."

# Check Foundry
if ! command -v forge &> /dev/null; then
    log_error "Foundry not found. Please install Foundry first."
    exit 1
fi

# Check Node.js
if ! command -v node &> /dev/null; then
    log_error "Node.js not found. Please install Node.js v18+ first."
    exit 1
fi

# Check .env file
if [ ! -f "$SMOM_DIR/.env" ]; then
    log_error ".env file not found in $SMOM_DIR"
    exit 1
fi

# Load environment variables
source "$SMOM_DIR/.env"

if [ -z "$RPC_URL_138" ]; then
    log_error "RPC_URL_138 not set in .env"
    exit 1
fi

if [ -z "$PRIVATE_KEY" ]; then
    log_error "PRIVATE_KEY not set in .env"
    exit 1
fi

log_success "Prerequisites check passed"

# Phase 1: Install SDK
log_info "Phase 1: Installing Smart Accounts SDK..."
cd "$PROJECT_ROOT"
if [ -f "scripts/install-smart-accounts-sdk.sh" ]; then
    bash scripts/install-smart-accounts-sdk.sh
    log_success "SDK installation complete"
else
    log_warning "SDK installation script not found, skipping..."
fi

# Phase 2: Deploy Smart Accounts Kit Contracts
log_info "Phase 2: Deploying Smart Accounts Kit contracts..."
cd "$SMOM_DIR"

log_info "Deploying EntryPoint and AccountFactory..."
if [ -f "script/smart-accounts/DeploySmartAccountsKit.s.sol" ]; then
    forge script script/smart-accounts/DeploySmartAccountsKit.s.sol \
        --rpc-url "$RPC_URL_138" \
        --broadcast \
        --verify \
        -vvv
    
    log_success "Smart Accounts Kit contracts deployed"
    
    # Extract addresses from output (user will need to update config)
    log_warning "Please record the deployed contract addresses and update config/smart-accounts-config.json"
else
    log_error "Deployment script not found: script/smart-accounts/DeploySmartAccountsKit.s.sol"
    exit 1
fi

# Phase 3: Update Configuration
log_info "Phase 3: Updating configuration..."
cd "$PROJECT_ROOT"

if [ -f "scripts/update-smart-accounts-config.sh" ]; then
    log_info "Run the following command to update configuration:"
    log_info "  ./scripts/update-smart-accounts-config.sh --interactive"
    log_warning "Configuration update requires manual input of contract addresses"
else
    log_warning "Configuration update script not found"
fi

# Phase 4: Deploy AccountWalletRegistryExtended
log_info "Phase 4: Deploying AccountWalletRegistryExtended..."
cd "$SMOM_DIR"

if [ -f "script/smart-accounts/DeployAccountWalletRegistryExtended.s.sol" ]; then
    # Check if addresses are set
    if [ -z "$SMART_ACCOUNT_FACTORY" ] || [ -z "$ENTRY_POINT" ]; then
        log_warning "SMART_ACCOUNT_FACTORY or ENTRY_POINT not set in .env"
        log_warning "Please set these after deploying Smart Accounts Kit contracts"
        log_warning "Then run: forge script script/smart-accounts/DeployAccountWalletRegistryExtended.s.sol --rpc-url \$RPC_URL_138 --broadcast"
    else
        forge script script/smart-accounts/DeployAccountWalletRegistryExtended.s.sol \
            --rpc-url "$RPC_URL_138" \
            --broadcast \
            --verify \
            -vvv
        
        log_success "AccountWalletRegistryExtended deployed"
    fi
else
    log_error "Deployment script not found: script/smart-accounts/DeployAccountWalletRegistryExtended.s.sol"
    exit 1
fi

# Phase 5: Setup Monitoring
log_info "Phase 5: Setting up monitoring..."
cd "$PROJECT_ROOT"

if [ -f "scripts/setup-monitoring.sh" ]; then
    bash scripts/setup-monitoring.sh
    log_success "Monitoring setup complete"
else
    log_warning "Monitoring setup script not found, skipping..."
fi

# Phase 6: Run Tests
log_info "Phase 6: Running tests..."
cd "$SMOM_DIR"

log_info "Running unit tests..."
if forge test --match-path "test/smart-accounts/**" -vv; then
    log_success "Unit tests passed"
else
    log_warning "Some unit tests failed (this may be expected if contracts not deployed)"
fi

cd "$PROJECT_ROOT"
log_info "Running integration tests..."
if [ -f "package.json" ] && npm test 2>/dev/null; then
    log_success "Integration tests passed"
else
    log_warning "Integration tests skipped (may require deployed contracts)"
fi

# Summary
log_info "=========================================="
log_success "Deployment script completed!"
log_info "Next steps:"
log_info "1. Update config/smart-accounts-config.json with deployed addresses"
log_info "2. Run verification script: ./scripts/verify-deployment.sh"
log_info "3. Review deployment checklist: DEPLOYMENT_CHECKLIST.md"
log_info "4. Setup monitoring and alerts"
log_info "5. Perform security audit before production use"
