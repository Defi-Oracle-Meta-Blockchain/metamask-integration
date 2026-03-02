#!/bin/bash

# Setup Token Logo Hosting for MetaMask
# This script creates logo hosting configuration and updates token lists

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
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
log_info "Token Logo Hosting Setup"
log_info "========================================="
log_info ""

# Create logo directory structure
LOGO_DIR="$PROJECT_ROOT/token-logos"
mkdir -p "$LOGO_DIR"/{32x32,128x128,256x256,512x512}
mkdir -p "$LOGO_DIR"/blockscout/images/tokens

log_info "Created logo directory structure"

# Create logo hosting guide
cat > "$LOGO_DIR/LOGO_HOSTING_GUIDE.md" << 'EOF'
# Token Logo Hosting Guide

## Overview

Token logos should be hosted at:
```
https://explorer.d-bis.org/images/tokens/{token-address}.png
```

## Logo Requirements

### Sizes
- **32x32**: Small icons (MetaMask token list)
- **128x128**: Medium icons (MetaMask wallet)
- **256x256**: Large icons (dApps)
- **512x512**: High resolution (Blockscout)

### Format
- **Format**: PNG (recommended) or SVG
- **Background**: Transparent (preferred)
- **Aspect Ratio**: 1:1 (square)
- **File Size**: < 100KB per logo

## Token Logos Needed

### cUSDT (Compliant Tether USD)
- **Address**: `0x93E66202A11B1772E55407B32B44e5Cd8eda7f22`
- **Logo Source**: Can use official USDT logo
- **URL**: https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0xdAC17F958D2ee523a2206206994597C13D831ec7/logo.png

### cUSDC (Compliant USD Coin)
- **Address**: `0xf22258f57794CC8E06237084b353Ab30fFfa640b`
- **Logo Source**: Can use official USDC logo
- **URL**: https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48/logo.png

### WETH (Wrapped Ether)
- **Address**: `0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2`
- **Logo Source**: Can use WETH logo
- **URL**: https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2/logo.png

### WETH10 (Wrapped Ether v10)
- **Address**: `0xf4BB2e28688e89fCcE3c0580D37d36A7672E8A9f`
- **Logo Source**: Can use WETH logo
- **URL**: https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2/logo.png

### LINK (Chainlink Token)
- **Address**: `0xb7721dD53A8c629d9f1Ba31a5819AFe250002b03`
- **Logo Source**: Chainlink logo
- **URL**: https://raw.githubusercontent.com/chainlink/chainlink-docs/main/docs/images/chainlink-logo.svg

### ETH/USD Oracle
- **Address**: `0x3304b747E565a97ec8AC220b0B6A1f6ffDB837e6`
- **Logo Source**: Custom oracle logo (needs creation)

## Hosting Options

### Option 1: Blockscout (Recommended)

1. **Upload logos to Blockscout**:
   ```bash
   # Upload to Blockscout static files
   /var/www/blockscout/priv/static/images/tokens/
   ```

2. **Logo naming convention**:
   ```
   {token-address}.png
   {token-address}-32.png (for 32x32)
   {token-address}-128.png (for 128x128)
   ```

3. **Access URL**:
   ```
   https://explorer.d-bis.org/images/tokens/{token-address}.png
   ```

### Option 2: CDN/Static Hosting

1. **Upload to CDN** (Cloudflare, AWS S3, etc.)
2. **Update token list with CDN URLs**
3. **Ensure CORS is enabled**

### Option 3: IPFS

1. **Upload logos to IPFS**
2. **Pin logos**
3. **Update token list with IPFS URLs**

## Logo Download Script

Use this script to download logos from Trust Wallet assets:

```bash
#!/bin/bash
# Download token logos from Trust Wallet assets

TOKENS=(
  "0xdAC17F958D2ee523a2206206994597C13D831ec7:cusdt"
  "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48:cusdc"
  "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2:weth"
)

for token in "${TOKENS[@]}"; do
  IFS=':' read -r address name <<< "$token"
  url="https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/$address/logo.png"
  wget -O "$name.png" "$url" || echo "Failed to download $name"
done
```

## Blockscout Configuration

Add to Blockscout configuration:

```elixir
config :blockscout_web, BlockscoutWeb.Endpoint,
  logo_serving: [
    enabled: true,
    base_path: "/images/tokens",
    fallback_logo: "/images/default-token.png"
  ]
```

## Verification

Test logo URLs:

```bash
# Test cUSDT logo
curl -I https://explorer.d-bis.org/images/tokens/0x93E66202A11B1772E55407B32B44e5Cd8eda7f22.png

# Test cUSDC logo
curl -I https://explorer.d-bis.org/images/tokens/0xf22258f57794CC8E06237084b353Ab30fFfa640b.png
```

Expected: HTTP 200 with Content-Type: image/png
EOF

log_success "Created: $LOGO_DIR/LOGO_HOSTING_GUIDE.md"

# Create logo download script
cat > "$LOGO_DIR/download-logos.sh" << 'EOF'
#!/bin/bash
# Download token logos from Trust Wallet assets

set -e

LOGO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Token addresses and names
declare -A TOKENS=(
  ["0xdAC17F958D2ee523a2206206994597C13D831ec7"]="cusdt"
  ["0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"]="cusdc"
  ["0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"]="weth"
)

BASE_URL="https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets"

for address in "${!TOKENS[@]}"; do
  name="${TOKENS[$address]}"
  url="$BASE_URL/$address/logo.png"
  
  echo "Downloading $name logo from $url..."
  wget -q -O "$LOGO_DIR/$name.png" "$url" && echo "✓ Downloaded $name.png" || echo "✗ Failed to download $name"
done

echo ""
echo "Logos downloaded to: $LOGO_DIR"
EOF

chmod +x "$LOGO_DIR/download-logos.sh"
log_success "Created: $LOGO_DIR/download-logos.sh"

# Create nginx configuration for logo serving
cat > "$LOGO_DIR/nginx-logo-serving.conf" << 'EOF'
# Nginx configuration for token logo serving
# Add to your nginx server block for explorer.d-bis.org

location /images/tokens/ {
    alias /var/www/blockscout/priv/static/images/tokens/;
    
    # CORS headers
    add_header Access-Control-Allow-Origin * always;
    add_header Access-Control-Allow-Methods "GET, OPTIONS" always;
    add_header Access-Control-Max-Age 3600 always;
    
    # Cache logos for 1 year
    expires 1y;
    add_header Cache-Control "public, immutable";
    
    # Fallback to default logo if not found
    try_files $uri /images/default-token.png =404;
}

# Default token logo
location = /images/default-token.png {
    alias /var/www/blockscout/priv/static/images/default-token.png;
    expires 1y;
    add_header Cache-Control "public, immutable";
}
EOF

log_success "Created: $LOGO_DIR/nginx-logo-serving.conf"

log_info ""
log_info "========================================="
log_info "Logo Hosting Setup Complete!"
log_info "========================================="
log_info ""
log_info "Files created in: $LOGO_DIR"
log_info "  - LOGO_HOSTING_GUIDE.md (hosting guide)"
log_info "  - download-logos.sh (logo download script)"
log_info "  - nginx-logo-serving.conf (nginx config)"
log_info ""
log_info "Next steps:"
log_info "1. Run download-logos.sh to download logos"
log_info "2. Upload logos to Blockscout or CDN"
log_info "3. Update token list with logo URLs"
log_info "4. Test logo URLs"
log_info ""
