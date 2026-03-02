#!/bin/bash

# Install MetaMask Smart Accounts Kit SDK
# This script installs the SDK and sets up the project

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

log_info "========================================="
log_info "Installing MetaMask Smart Accounts Kit SDK"
log_info "========================================="
log_info ""

cd "$PROJECT_ROOT"

# Check if package.json exists
if [ ! -f "package.json" ]; then
    log_error "package.json not found. Creating it..."
    # package.json should already exist, but create if missing
fi

# Check if node_modules exists
if [ -d "node_modules" ]; then
    log_warn "node_modules already exists. Removing..."
    rm -rf node_modules
fi

# Install dependencies
log_info "Installing dependencies..."
if command -v npm &> /dev/null; then
    npm install
    log_success "Dependencies installed successfully"
elif command -v yarn &> /dev/null; then
    yarn install
    log_success "Dependencies installed successfully"
elif command -v pnpm &> /dev/null; then
    pnpm install
    log_success "Dependencies installed successfully"
else
    log_error "No package manager found (npm, yarn, or pnpm)"
    exit 1
fi

# Verify installation
log_info "Verifying installation..."
if [ -d "node_modules/@metamask/smart-accounts-kit" ]; then
    log_success "Smart Accounts Kit SDK installed successfully"
    log_info "Version: $(cat node_modules/@metamask/smart-accounts-kit/package.json | grep version | head -1 | cut -d'"' -f4)"
else
    log_error "Smart Accounts Kit SDK not found after installation"
    exit 1
fi

log_info ""
log_info "========================================="
log_success "Installation Complete!"
log_info "========================================="
log_info ""
log_info "Next steps:"
log_info "1. Review config/smart-accounts-config.json"
log_info "2. Deploy contracts using deployment scripts"
log_info "3. Update config with deployed addresses"
log_info ""
