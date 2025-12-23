#!/usr/bin/env bash
# Script to prepare token list for public hosting
# Usage: ./host-token-list.sh [hosting-method]
# Options: github, ipfs, local

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TOKEN_LIST_FILE="$PROJECT_ROOT/docs/METAMASK_TOKEN_LIST.json"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

HOSTING_METHOD="${1:-github}"

log_info "========================================="
log_info "Token List Hosting Preparation"
log_info "========================================="
log_info ""
log_info "Method: $HOSTING_METHOD"
log_info "Token List: $TOKEN_LIST_FILE"
log_info ""

# Validate token list JSON
if [ ! -f "$TOKEN_LIST_FILE" ]; then
    log_error "Token list file not found: $TOKEN_LIST_FILE"
    exit 1
fi

if ! jq empty "$TOKEN_LIST_FILE" 2>/dev/null; then
    log_error "Token list JSON is invalid"
    exit 1
fi

log_success "Token list JSON is valid"

# Extract token list info
TOKEN_LIST_NAME=$(jq -r '.name' "$TOKEN_LIST_FILE")
TOKEN_LIST_VERSION=$(jq -r '.version | "\(.major).\(.minor).\(.patch)"' "$TOKEN_LIST_FILE")
TOKEN_COUNT=$(jq '.tokens | length' "$TOKEN_LIST_FILE")

log_info "Token List: $TOKEN_LIST_NAME v$TOKEN_LIST_VERSION"
log_info "Tokens: $TOKEN_COUNT"
log_info ""

case "$HOSTING_METHOD" in
    github)
        log_info "Preparing for GitHub Pages hosting..."
        log_info ""
        log_info "Steps to host on GitHub Pages:"
        log_info "1. Create a GitHub repository (or use existing)"
        log_info "2. Copy token-list.json to repository root"
        log_info "3. Enable GitHub Pages in repository settings"
        log_info "4. Access at: https://<username>.github.io/<repo>/token-list.json"
        log_info ""
        log_info "Creating token-list.json for GitHub..."
        
        OUTPUT_FILE="$PROJECT_ROOT/token-list.json"
        cp "$TOKEN_LIST_FILE" "$OUTPUT_FILE"
        log_success "Created: $OUTPUT_FILE"
        log_info ""
        log_info "Next steps:"
        log_info "1. git add token-list.json"
        log_info "2. git commit -m 'Add MetaMask token list'"
        log_info "3. git push"
        log_info "4. Enable GitHub Pages in repo settings"
        ;;
        
    ipfs)
        log_info "Preparing for IPFS hosting..."
        log_info ""
        log_info "Note: Requires IPFS node running"
        log_info ""
        
        if command -v ipfs &> /dev/null; then
            log_info "IPFS detected, adding file..."
            IPFS_HASH=$(ipfs add -q "$TOKEN_LIST_FILE" 2>/dev/null || echo "")
            
            if [ -n "$IPFS_HASH" ]; then
                log_success "File added to IPFS"
                log_info "IPFS Hash: $IPFS_HASH"
                log_info "Access at: https://ipfs.io/ipfs/$IPFS_HASH"
                log_info "Or: https://gateway.pinata.cloud/ipfs/$IPFS_HASH"
            else
                log_warn "Could not add to IPFS (node may not be running)"
                log_info "Manual steps:"
                log_info "1. Start IPFS: ipfs daemon"
                log_info "2. Add file: ipfs add $TOKEN_LIST_FILE"
                log_info "3. Pin file: ipfs pin add <hash>"
            fi
        else
            log_warn "IPFS not installed"
            log_info "Install IPFS: https://docs.ipfs.io/install/"
            log_info "Or use IPFS web interface: https://ipfs.io"
        fi
        ;;
        
    local)
        log_info "Preparing for local hosting..."
        log_info ""
        log_info "For local testing or custom server hosting:"
        log_info ""
        log_info "1. Copy token-list.json to your web server"
        log_info "2. Ensure HTTPS is enabled"
        log_info "3. Set CORS headers:"
        log_info "   Access-Control-Allow-Origin: *"
        log_info "   Access-Control-Allow-Methods: GET, OPTIONS"
        log_info "   Content-Type: application/json"
        log_info ""
        log_info "Example nginx config:"
        echo ""
        cat << 'EOF'
location /token-list.json {
    add_header Access-Control-Allow-Origin *;
    add_header Access-Control-Allow-Methods "GET, OPTIONS";
    add_header Content-Type application/json;
    try_files $uri =404;
}
EOF
        echo ""
        ;;
        
    *)
        log_error "Unknown hosting method: $HOSTING_METHOD"
        log_info "Available methods: github, ipfs, local"
        exit 1
        ;;
esac

log_info ""
log_info "Token List Summary:"
log_info "  Name: $TOKEN_LIST_NAME"
log_info "  Version: $TOKEN_LIST_VERSION"
log_info "  Tokens: $TOKEN_COUNT"
log_info ""

# List tokens
log_info "Tokens in list:"
jq -r '.tokens[] | "  - \(.symbol) (\(.name)): \(.address)"' "$TOKEN_LIST_FILE"

log_info ""
log_success "Token list preparation complete!"
log_info ""
log_info "To add to MetaMask:"
log_info "1. Settings → Security & Privacy → Token Lists"
log_info "2. Add custom token list URL"
log_info "3. Enter your hosted URL"

