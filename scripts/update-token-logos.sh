#!/bin/bash

# Update all token lists with proper logo URLs
# This script updates logoURI fields in all token list files

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
log_info "Update Token Logos in Token Lists"
log_info "========================================="
log_info ""

# Token logo mapping
declare -A TOKEN_LOGOS=(
  # Format: address=logo_url
  ["0x3304b747E565a97ec8AC220b0B6A1f6ffDB837e6"]="https://explorer.d-bis.org/images/tokens/0x3304b747E565a97ec8AC220b0B6A1f6ffDB837e6.png"
  ["0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"]="https://explorer.d-bis.org/images/tokens/0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2.png"
  ["0xf4BB2e28688e89fCcE3c0580D37d36A7672E8A9f"]="https://explorer.d-bis.org/images/tokens/0xf4BB2e28688e89fCcE3c0580D37d36A7672E8A9f.png"
  ["0xb7721dD53A8c629d9f1Ba31a5819AFe250002b03"]="https://explorer.d-bis.org/images/tokens/0xb7721dD53A8c629d9f1Ba31a5819AFe250002b03.png"
  ["0x93E66202A11B1772E55407B32B44e5Cd8eda7f22"]="https://explorer.d-bis.org/images/tokens/0x93E66202A11B1772E55407B32B44e5Cd8eda7f22.png"
  ["0xf22258f57794CC8E06237084b353Ab30fFfa640b"]="https://explorer.d-bis.org/images/tokens/0xf22258f57794CC8E06237084b353Ab30fFfa640b.png"
)

# Token list files to update
TOKEN_LISTS=(
  "$PROJECT_ROOT/../token-lists/lists/dbis-138.tokenlist.json"
  "$PROJECT_ROOT/docs/METAMASK_TOKEN_LIST.json"
  "$PROJECT_ROOT/config/token-list.json"
  "$PROJECT_ROOT/config/complete-token-list.json"
)

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    log_error "jq is required but not installed"
    exit 1
fi

# Function to update logo in token list
update_token_logo() {
    local file=$1
    local address=$2
    local logo_url=$3
    
    if [ ! -f "$file" ]; then
        log_warn "File not found: $file"
        return
    fi
    
    # Update logoURI for matching address (case-insensitive)
    jq --arg addr "$address" --arg logo "$logo_url" \
       '(.tokens[]? | select((.address | ascii_downcase) == ($addr | ascii_downcase)) | .logoURI) = $logo' \
       "$file" > "${file}.tmp" && mv "${file}.tmp" "$file" 2>/dev/null || {
        log_warn "Failed to update logo for $address in $file"
        rm -f "${file}.tmp"
    }
}

# Update each token list
for token_list in "${TOKEN_LISTS[@]}"; do
    if [ ! -f "$token_list" ]; then
        log_warn "Token list not found: $token_list"
        continue
    fi
    
    log_info "Updating: $token_list"
    
    for address in "${!TOKEN_LOGOS[@]}"; do
        logo_url="${TOKEN_LOGOS[$address]}"
        update_token_logo "$token_list" "$address" "$logo_url"
    done
    
    log_success "Updated: $token_list"
done

log_info ""
log_info "========================================="
log_info "Token Logo Update Complete!"
log_info "========================================="
log_info ""
log_info "Updated token lists with logo URLs:"
for token_list in "${TOKEN_LISTS[@]}"; do
    if [ -f "$token_list" ]; then
        log_info "  - $token_list"
    fi
done
log_info ""
log_info "Logo URLs point to: https://explorer.d-bis.org/images/tokens/{address}.png"
log_info ""
