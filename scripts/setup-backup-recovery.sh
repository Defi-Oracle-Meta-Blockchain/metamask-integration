#!/bin/bash

# Setup Backup and Recovery Procedures for Smart Accounts
# This script sets up backup and recovery procedures

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
log_info "Setup Backup and Recovery Procedures"
log_info "========================================="
log_info ""

BACKUP_DIR="$PROJECT_ROOT/backups"
mkdir -p "$BACKUP_DIR"

# Create backup script
cat > "$BACKUP_DIR/backup-smart-accounts-config.sh" << 'EOF'
#!/bin/bash
# Backup Smart Accounts configuration

BACKUP_DIR="$(dirname "$0")"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Backup configuration files
cp config/smart-accounts-config.json "$BACKUP_DIR/smart-accounts-config_${TIMESTAMP}.json"
cp config/monitoring-config.json "$BACKUP_DIR/monitoring-config_${TIMESTAMP}.json"

echo "Backup completed: ${TIMESTAMP}"
EOF

chmod +x "$BACKUP_DIR/backup-smart-accounts-config.sh"

# Create recovery script
cat > "$BACKUP_DIR/recover-smart-accounts-config.sh" << 'EOF'
#!/bin/bash
# Recover Smart Accounts configuration from backup

BACKUP_DIR="$(dirname "$0")"

if [ -z "$1" ]; then
    echo "Usage: $0 <backup_timestamp>"
    echo "Available backups:"
    ls -1 "$BACKUP_DIR"/*.json | xargs -n1 basename
    exit 1
fi

TIMESTAMP=$1

# Restore configuration files
cp "$BACKUP_DIR/smart-accounts-config_${TIMESTAMP}.json" config/smart-accounts-config.json
cp "$BACKUP_DIR/monitoring-config_${TIMESTAMP}.json" config/monitoring-config.json

echo "Configuration restored from: ${TIMESTAMP}"
EOF

chmod +x "$BACKUP_DIR/recover-smart-accounts-config.sh"

log_success "Backup and recovery procedures set up!"
log_info ""
log_info "Backup directory: $BACKUP_DIR"
log_info "Backup script: $BACKUP_DIR/backup-smart-accounts-config.sh"
log_info "Recovery script: $BACKUP_DIR/recover-smart-accounts-config.sh"
log_info ""
