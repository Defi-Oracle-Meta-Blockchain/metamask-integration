#!/bin/bash

# Prepare token list for submission to aggregators (CoinGecko, Uniswap, etc.)

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
log_info "Token List Submission Preparation"
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

# Extract token list info
TOKEN_LIST_NAME=$(jq -r '.name' "$TOKEN_LIST")
TOKEN_LIST_VERSION=$(jq -r '.version | "\(.major).\(.minor).\(.patch)"' "$TOKEN_LIST")
TOKEN_COUNT=$(jq '.tokens | length' "$TOKEN_LIST")

log_info "Token List: $TOKEN_LIST_NAME v$TOKEN_LIST_VERSION"
log_info "Tokens: $TOKEN_COUNT"
log_info ""

# Create submission directory
SUBMISSION_DIR="$PROJECT_ROOT/token-list-submissions"
mkdir -p "$SUBMISSION_DIR"

# Copy token list
cp "$TOKEN_LIST" "$SUBMISSION_DIR/dbis-138.tokenlist.json"
log_success "Created: $SUBMISSION_DIR/dbis-138.tokenlist.json"

# Create CoinGecko submission package
log_info "Creating CoinGecko submission package..."
cat > "$SUBMISSION_DIR/coingecko-submission.md" << EOF
# CoinGecko Token List Submission - ChainID 138

## Network Information

- **Chain ID**: 138
- **Network Name**: DeFi Oracle Meta Mainnet
- **RPC URL**: https://rpc.d-bis.org
- **Explorer**: https://explorer.d-bis.org

## Token List

- **File**: dbis-138.tokenlist.json
- **Version**: $TOKEN_LIST_VERSION
- **Tokens**: $TOKEN_COUNT

## Submission Method

1. Go to https://www.coingecko.com/en/api
2. Navigate to Token List submission
3. Upload dbis-138.tokenlist.json
4. Provide network information
5. Submit for review

## Contact

For questions about this submission, please contact the network maintainers.

## Token List URL

Once hosted, the token list will be available at:
\`https://[hosted-url]/dbis-138.tokenlist.json\`
EOF

log_success "Created: $SUBMISSION_DIR/coingecko-submission.md"

# Create Uniswap submission package
log_info "Creating Uniswap submission package..."
cat > "$SUBMISSION_DIR/uniswap-submission.md" << EOF
# Uniswap Token List Submission - ChainID 138

## Network Information

- **Chain ID**: 138
- **Network Name**: DeFi Oracle Meta Mainnet
- **RPC URL**: https://rpc.d-bis.org
- **Explorer**: https://explorer.d-bis.org

## Token List

- **File**: dbis-138.tokenlist.json
- **Version**: $TOKEN_LIST_VERSION
- **Tokens**: $TOKEN_COUNT

## Submission Method

1. Go to https://tokenlists.org/
2. Click "Submit a List"
3. Provide token list URL (once hosted)
4. Fill out submission form
5. Submit for review

## Requirements

- [x] Token list follows Token Lists schema
- [x] All tokens are deployed on-chain
- [x] Token metadata is accurate
- [x] Logo URLs are accessible
- [x] Network is stable

## Contact

For questions about this submission, please contact the network maintainers.
EOF

log_success "Created: $SUBMISSION_DIR/uniswap-submission.md"

# Create 1inch submission package
log_info "Creating 1inch submission package..."
cat > "$SUBMISSION_DIR/1inch-submission.md" << EOF
# 1inch Token List Submission - ChainID 138

## Network Information

- **Chain ID**: 138
- **Network Name**: DeFi Oracle Meta Mainnet
- **RPC URL**: https://rpc.d-bis.org
- **Explorer**: https://explorer.d-bis.org

## Token List

- **File**: dbis-138.tokenlist.json
- **Version**: $TOKEN_LIST_VERSION
- **Tokens**: $TOKEN_COUNT

## Submission Method

1. Contact 1inch team via their support channels
2. Provide token list URL (once hosted)
3. Request ChainID 138 integration
4. Provide network information

## Requirements

- [x] Token list follows Token Lists schema
- [x] All tokens are deployed on-chain
- [x] Network has sufficient liquidity
- [x] Network is stable

## Contact

- 1inch Support: https://help.1inch.io/
- 1inch Discord: https://discord.gg/1inch
EOF

log_success "Created: $SUBMISSION_DIR/1inch-submission.md"

# Create general submission guide
cat > "$SUBMISSION_DIR/SUBMISSION_GUIDE.md" << 'EOF'
# Token List Submission Guide

This directory contains materials for submitting the ChainID 138 token list to various aggregators.

## Files

- `dbis-138.tokenlist.json` - The token list file
- `coingecko-submission.md` - CoinGecko submission instructions
- `uniswap-submission.md` - Uniswap/tokenlists.org submission instructions
- `1inch-submission.md` - 1inch submission instructions

## Prerequisites

Before submitting, ensure:

1. ✅ Token list is hosted on a public URL (HTTPS)
2. ✅ All tokens are deployed and verified on-chain
3. ✅ Token metadata is accurate
4. ✅ Logo URLs are accessible
5. ✅ Network is stable and operational

## Submission Order

1. **Host Token List** (Priority 1)
   - Host on GitHub Pages, IPFS, or custom domain
   - Ensure HTTPS and CORS headers are configured

2. **Submit to Token Lists** (Priority 2)
   - Submit to tokenlists.org (Uniswap)
   - This enables auto-discovery in MetaMask

3. **Submit to CoinGecko** (Priority 3)
   - Enables price data and market information

4. **Submit to 1inch** (Priority 4)
   - Enables DEX aggregation support

## Token List URL Format

Once hosted, the token list should be accessible at:
```
https://[your-domain]/dbis-138.tokenlist.json
```

## Verification

After submission, verify:
- [ ] Token list is accessible via URL
- [ ] Tokens appear in MetaMask Portfolio
- [ ] Token logos display correctly
- [ ] Token metadata is accurate
- [ ] Network is listed on aggregators

## Support

For questions or issues with submissions, contact the network maintainers.
EOF

log_success "Created: $SUBMISSION_DIR/SUBMISSION_GUIDE.md"

# List tokens
log_info ""
log_info "Tokens in list:"
jq -r '.tokens[] | "  - \(.symbol) (\(.name)): \(.address)"' "$TOKEN_LIST"

log_info ""
log_info "========================================="
log_info "Submission Preparation Complete!"
log_info "========================================="
log_info ""
log_info "Files created in: $SUBMISSION_DIR"
log_info ""
log_info "Next steps:"
log_info "1. Host token list on public URL"
log_info "2. Review submission guides"
log_info "3. Submit to aggregators"
log_info ""
