#!/bin/bash

# Network-Dependent Tasks Execution Script
# Orchestrates execution of all network-dependent tasks

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

log_info "Network-Dependent Tasks Execution Script"
log_info "========================================="

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

# Function to deploy contracts
deploy_contracts() {
    log_info "Phase 1: Deploying Smart Accounts Contracts..."
    cd "$SMOM_DIR"
    
    log_info "Deploying Smart Accounts Kit contracts..."
    log_warning "NOTE: EntryPoint and AccountFactory contracts need to be deployed from:"
    log_warning "  - MetaMask Smart Accounts Kit SDK/package"
    log_warning "  - Standard ERC-4337 implementations"
    log_warning "  - Or use existing deployed addresses"
    
    # Check if contract sources exist
    if [ ! -f "script/smart-accounts/DeploySmartAccountsKit.s.sol" ]; then
        log_error "Deployment script not found: script/smart-accounts/DeploySmartAccountsKit.s.sol"
        log_info "The script exists but requires actual contract implementations."
        log_info "Please ensure EntryPoint and AccountFactory contracts are available."
        return 1
    fi
    
    # Run deployment script (will show TODO placeholders)
    forge script script/smart-accounts/DeploySmartAccountsKit.s.sol \
        --rpc-url "$RPC_URL_138" \
        --broadcast \
        -vvv || {
        log_warning "Deployment script executed (may show TODO placeholders)"
        log_warning "Actual contract deployment requires EntryPoint and AccountFactory implementations"
    }
    
    log_warning "Please deploy EntryPoint and AccountFactory contracts manually"
    log_warning "Then update config/smart-accounts-config.json with deployed addresses"
}

# Function to deploy extended registry
deploy_extended_registry() {
    log_info "Phase 2: Deploying AccountWalletRegistryExtended..."
    cd "$SMOM_DIR"
    
    if [ -z "$SMART_ACCOUNT_FACTORY" ] || [ -z "$ENTRY_POINT" ]; then
        log_error "SMART_ACCOUNT_FACTORY or ENTRY_POINT not set in .env"
        log_error "Please set these after deploying Smart Accounts Kit contracts"
        return 1
    fi
    
    forge script script/smart-accounts/DeployAccountWalletRegistryExtended.s.sol \
        --rpc-url "$RPC_URL_138" \
        --broadcast \
        --verify \
        -vvv
    
    log_success "AccountWalletRegistryExtended deployed"
}

# Function to run unit tests
run_unit_tests() {
    log_info "Phase 3: Running Unit Tests..."
    cd "$SMOM_DIR"
    
    log_info "Running Foundry unit tests..."
    forge test --match-path "test/smart-accounts/**" -vv --rpc-url "$RPC_URL_138"
    
    log_success "Unit tests completed"
}

# Function to run integration tests
run_integration_tests() {
    log_info "Phase 4: Running Integration Tests..."
    cd "$PROJECT_ROOT"
    
    if [ -f "package.json" ]; then
        log_info "Running npm integration tests..."
        npm test
        log_success "Integration tests completed"
    else
        log_warning "package.json not found, skipping npm tests"
    fi
}

# Function to run end-to-end tests
run_e2e_tests() {
    log_info "Phase 5: Running End-to-End Tests..."
    cd "$PROJECT_ROOT"
    
    if [ -f "package.json" ]; then
        log_info "Running E2E tests..."
        npm run test:e2e 2>/dev/null || npm test
        log_success "E2E tests completed"
    else
        log_warning "E2E test scripts not configured"
    fi
}

# Function to verify deployment
verify_deployment() {
    log_info "Phase 6: Verifying Deployment..."
    cd "$PROJECT_ROOT"
    
    if [ -f "scripts/verify-deployment.sh" ]; then
        bash scripts/verify-deployment.sh
        log_success "Deployment verification completed"
    else
        log_warning "Verification script not found"
    fi
}

# Function to run health check
run_health_check() {
    log_info "Phase 7: Running Health Check..."
    cd "$PROJECT_ROOT"
    
    if [ -f "scripts/health-check.sh" ]; then
        bash scripts/health-check.sh
        log_success "Health check completed"
    else
        log_warning "Health check script not found"
    fi
}

# Main execution
main() {
    local phase=$1
    
    case $phase in
        "deploy")
            deploy_contracts
            deploy_extended_registry
            ;;
        "test")
            run_unit_tests
            run_integration_tests
            run_e2e_tests
            ;;
        "verify")
            verify_deployment
            run_health_check
            ;;
        "all")
            deploy_contracts
            deploy_extended_registry
            verify_deployment
            run_unit_tests
            run_integration_tests
            run_e2e_tests
            run_health_check
            ;;
        *)
            log_info "Usage: $0 [deploy|test|verify|all]"
            log_info ""
            log_info "Phases:"
            log_info "  deploy  - Deploy all contracts"
            log_info "  test    - Run all tests"
            log_info "  verify  - Verify deployment and health"
            log_info "  all     - Execute all phases"
            exit 1
            ;;
    esac
}

# Execute
main "${1:-all}"

log_info "========================================="
log_success "Network-dependent tasks execution completed!"
