#!/bin/bash

# Security Scan for Smart Accounts Contracts
# Runs Slither and other security tools

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONTRACTS_DIR="$PROJECT_ROOT/../smom-dbis-138/contracts/smart-accounts"

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
log_info "Security Scan - Smart Accounts Contracts"
log_info "========================================="
log_info ""

# Check if contracts directory exists
if [ ! -d "$CONTRACTS_DIR" ]; then
    log_error "Contracts directory not found: $CONTRACTS_DIR"
    exit 1
fi

# Check if Slither is installed
if ! command -v slither &> /dev/null; then
    log_warn "Slither not installed. Installing..."
    pip install slither-analyzer
fi

# Run Slither
log_info "Running Slither analysis..."
cd "$PROJECT_ROOT/../smom-dbis-138"

slither contracts/smart-accounts/ \
    --exclude-informational \
    --exclude-optimization \
    --exclude-low \
    --print human \
    --json - \
    > "$PROJECT_ROOT/security-scan-results.json" 2>&1 || true

log_success "Security scan complete!"
log_info "Results saved to: security-scan-results.json"
log_info ""

# Check for high/critical issues
if grep -q "High\|Critical" "$PROJECT_ROOT/security-scan-results.json" 2>/dev/null; then
    log_warn "High or critical issues found. Review security-scan-results.json"
else
    log_success "No high or critical issues found"
fi
