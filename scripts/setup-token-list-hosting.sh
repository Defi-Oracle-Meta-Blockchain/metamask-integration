#!/bin/bash

# Setup Public Token List Hosting for MetaMask
# This script prepares token list for hosting on various platforms

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TOKEN_LIST="$PROJECT_ROOT/../token-lists/lists/dbis-138.tokenlist.json"

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
log_info "Token List Hosting Setup"
log_info "========================================="
log_info ""

# Validate token list
if [ ! -f "$TOKEN_LIST" ]; then
    log_error "Token list not found: $TOKEN_LIST"
    exit 1
fi

if ! jq empty "$TOKEN_LIST" 2>/dev/null; then
    log_error "Token list JSON is invalid"
    exit 1
fi

log_success "Token list JSON is valid"

# Create hosting directory
HOSTING_DIR="$PROJECT_ROOT/token-list-hosting"
mkdir -p "$HOSTING_DIR"

# Copy token list
cp "$TOKEN_LIST" "$HOSTING_DIR/token-list.json"
log_success "Copied token list to hosting directory"

# Create GitHub Pages setup
log_info "Creating GitHub Pages setup..."
cat > "$HOSTING_DIR/github-pages-setup.md" << 'EOF'
# GitHub Pages Token List Hosting

## Setup Steps

1. **Create GitHub Repository**:
   ```bash
   git init
   git add token-list.json
   git commit -m "Add ChainID 138 token list"
   git remote add origin https://github.com/your-org/token-list.git
   git push -u origin main
   ```

2. **Enable GitHub Pages**:
   - Go to repository Settings
   - Navigate to Pages
   - Source: Deploy from a branch
   - Branch: main
   - Folder: / (root)
   - Click Save

3. **Access Token List**:
   - URL: `https://your-org.github.io/token-list/token-list.json`
   - Or custom domain: `https://your-domain.com/token-list.json`

4. **Add to MetaMask**:
   - Settings → Security & Privacy → Token Lists
   - Add custom token list
   - Enter: `https://your-org.github.io/token-list/token-list.json`

## CORS Configuration

GitHub Pages automatically serves with CORS headers, so no additional configuration needed.

## Auto-Update

When you update token-list.json and push to main, GitHub Pages automatically updates.
EOF

log_success "Created: $HOSTING_DIR/github-pages-setup.md"

# Create nginx hosting configuration
log_info "Creating nginx hosting configuration..."
cat > "$HOSTING_DIR/nginx-token-list.conf" << 'EOF'
# Nginx configuration for token list hosting
# Add to your nginx server block

server {
    listen 443 ssl http2;
    server_name your-domain.com;

    # SSL Configuration
    ssl_certificate /etc/ssl/certs/your-domain.crt;
    ssl_certificate_key /etc/ssl/private/your-domain.key;

    # Token List Location
    location /token-list.json {
        alias /var/www/token-list/token-list.json;
        
        # CORS Headers
        add_header Access-Control-Allow-Origin * always;
        add_header Access-Control-Allow-Methods "GET, OPTIONS" always;
        add_header Access-Control-Allow-Headers "Content-Type" always;
        add_header Access-Control-Max-Age 3600 always;
        add_header Content-Type application/json always;
        
        # Cache for 1 hour
        expires 1h;
        add_header Cache-Control "public, must-revalidate";
        
        # Handle OPTIONS
        if ($request_method = OPTIONS) {
            add_header Access-Control-Allow-Origin * always;
            add_header Access-Control-Allow-Methods "GET, OPTIONS" always;
            add_header Access-Control-Max-Age 3600 always;
            add_header Content-Length 0;
            return 204;
        }
    }
}
EOF

log_success "Created: $HOSTING_DIR/nginx-token-list.conf"

# Create IPFS hosting guide
cat > "$HOSTING_DIR/ipfs-hosting-guide.md" << 'EOF'
# IPFS Token List Hosting

## Setup Steps

1. **Install IPFS**:
   ```bash
   # Download from https://ipfs.io
   # Or use package manager
   ```

2. **Start IPFS Node**:
   ```bash
   ipfs daemon
   ```

3. **Add Token List**:
   ```bash
   ipfs add token-list.json
   # Note the hash returned
   ```

4. **Pin Token List**:
   ```bash
   ipfs pin add <hash>
   ```

5. **Access Token List**:
   - IPFS Gateway: `https://ipfs.io/ipfs/<hash>`
   - Pinata Gateway: `https://gateway.pinata.cloud/ipfs/<hash>`
   - Cloudflare Gateway: `https://cloudflare-ipfs.com/ipfs/<hash>`

6. **Add to MetaMask**:
   - Use one of the gateway URLs above
   - Add to MetaMask token lists

## Pinning Services

For permanent hosting, use a pinning service:
- Pinata: https://pinata.cloud
- Infura: https://infura.io
- NFT.Storage: https://nft.storage

## Advantages

- Decentralized
- Permanent (if pinned)
- No single point of failure
- CORS-friendly gateways
EOF

log_success "Created: $HOSTING_DIR/ipfs-hosting-guide.md"

# Create hosting comparison
cat > "$HOSTING_DIR/HOSTING_COMPARISON.md" << 'EOF'
# Token List Hosting Options Comparison

## GitHub Pages

**Pros**:
- Free
- Easy setup
- Automatic HTTPS
- Version control
- Auto-updates

**Cons**:
- Requires GitHub account
- Public repository
- Limited customization

**Best For**: Quick setup, version control

---

## IPFS

**Pros**:
- Decentralized
- Permanent (if pinned)
- No single point of failure
- Multiple gateways

**Cons**:
- Requires IPFS node or pinning service
- Hash changes on update
- Gateway dependency

**Best For**: Decentralized hosting, permanent storage

---

## Custom Domain/CDN

**Pros**:
- Full control
- Custom domain
- CDN performance
- Professional appearance

**Cons**:
- Requires server/CDN
- SSL certificate needed
- Maintenance required
- Cost

**Best For**: Production, professional setup

---

## Recommendation

1. **Start**: GitHub Pages (quick, free)
2. **Production**: Custom domain with CDN
3. **Backup**: IPFS (permanent, decentralized)
EOF

log_success "Created: $HOSTING_DIR/HOSTING_COMPARISON.md"

log_info ""
log_info "========================================="
log_info "Token List Hosting Setup Complete!"
log_info "========================================="
log_info ""
log_info "Files created in: $HOSTING_DIR"
log_info "  - token-list.json (token list file)"
log_info "  - github-pages-setup.md (GitHub Pages guide)"
log_info "  - nginx-token-list.conf (nginx config)"
log_info "  - ipfs-hosting-guide.md (IPFS guide)"
log_info "  - HOSTING_COMPARISON.md (hosting options)"
log_info ""
log_info "Next steps:"
log_info "1. Choose hosting method"
log_info "2. Follow setup guide"
log_info "3. Host token list"
log_info "4. Add URL to MetaMask"
log_info "5. Verify token list works"
log_info ""
