#!/bin/bash

# Setup monitoring for Smart Accounts
# This script sets up monitoring configuration for Smart Accounts contracts

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
log_info "Setup Smart Accounts Monitoring"
log_info "========================================="
log_info ""

CONFIG_FILE="$PROJECT_ROOT/config/monitoring-config.json"

# Check if config exists
if [ ! -f "$CONFIG_FILE" ]; then
    log_error "Monitoring config not found: $CONFIG_FILE"
    exit 1
fi

log_info "Monitoring configuration file: $CONFIG_FILE"
log_info ""
log_info "To enable monitoring:"
log_info "1. Update contract addresses in config/monitoring-config.json"
log_info "2. Configure Prometheus endpoint"
log_info "3. Configure Grafana dashboards"
log_info "4. Set up alerting rules"
log_info ""
log_success "Monitoring setup complete!"
log_info ""
