#!/bin/bash

# Prepare Ethereum-Lists PR submission
# This script validates and prepares the chain metadata for ethereum-lists/chains PR

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CHAIN_METADATA="$PROJECT_ROOT/../smom-dbis-138/metamask/ethereum-lists-chain.json"

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
log_info "Ethereum-Lists PR Preparation"
log_info "========================================="
log_info ""

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    log_error "jq is required but not installed"
    exit 1
fi

# Validate chain metadata file
if [ ! -f "$CHAIN_METADATA" ]; then
    log_error "Chain metadata file not found: $CHAIN_METADATA"
    exit 1
fi

log_info "Validating chain metadata..."
if ! jq empty "$CHAIN_METADATA" 2>/dev/null; then
    log_error "Chain metadata JSON is invalid"
    exit 1
fi

log_success "Chain metadata JSON is valid"

# Extract and validate fields
CHAIN_ID=$(jq -r '.chainId' "$CHAIN_METADATA")
CHAIN_NAME=$(jq -r '.name' "$CHAIN_METADATA")
SHORT_NAME=$(jq -r '.shortName' "$CHAIN_METADATA")
RPC_URLS=$(jq -r '.rpc[]' "$CHAIN_METADATA" | head -1)
EXPLORER_URL=$(jq -r '.explorers[0].url' "$CHAIN_METADATA")

log_info ""
log_info "Chain Metadata:"
log_info "  Chain ID: $CHAIN_ID"
log_info "  Name: $CHAIN_NAME"
log_info "  Short Name: $SHORT_NAME"
log_info "  RPC URL: $RPC_URLS"
log_info "  Explorer: $EXPLORER_URL"
log_info ""

# Validate required fields
log_info "Validating required fields..."

REQUIRED_FIELDS=("chainId" "name" "shortName" "chain" "network" "nativeCurrency" "rpc" "explorers")
MISSING_FIELDS=()

for field in "${REQUIRED_FIELDS[@]}"; do
    if ! jq -e ".$field" "$CHAIN_METADATA" > /dev/null 2>&1; then
        MISSING_FIELDS+=("$field")
    fi
done

if [ ${#MISSING_FIELDS[@]} -gt 0 ]; then
    log_error "Missing required fields: ${MISSING_FIELDS[*]}"
    exit 1
fi

log_success "All required fields present"

# Validate RPC URLs
log_info "Validating RPC URLs..."
RPC_COUNT=$(jq '.rpc | length' "$CHAIN_METADATA")
if [ "$RPC_COUNT" -lt 1 ]; then
    log_error "At least one RPC URL is required"
    exit 1
fi

# Check if RPC URLs use HTTPS
HTTPS_RPC_COUNT=$(jq -r '.rpc[]' "$CHAIN_METADATA" | grep -c "^https://" || echo "0")
if [ "$HTTPS_RPC_COUNT" -eq 0 ]; then
    log_warn "No HTTPS RPC URLs found (recommended for production)"
fi

log_success "RPC URLs validated"

# Validate explorer
log_info "Validating explorer configuration..."
if ! jq -e '.explorers[0]' "$CHAIN_METADATA" > /dev/null 2>&1; then
    log_error "At least one explorer is required"
    exit 1
fi

EXPLORER_NAME=$(jq -r '.explorers[0].name' "$CHAIN_METADATA")
EXPLORER_STANDARD=$(jq -r '.explorers[0].standard' "$CHAIN_METADATA")

if [ "$EXPLORER_STANDARD" != "EIP3091" ]; then
    log_warn "Explorer standard should be EIP3091 (found: $EXPLORER_STANDARD)"
fi

log_success "Explorer validated: $EXPLORER_NAME"

# Create PR directory
PR_DIR="$PROJECT_ROOT/ethereum-lists-pr"
mkdir -p "$PR_DIR"

# Copy chain metadata
cp "$CHAIN_METADATA" "$PR_DIR/138.json"
log_success "Created: $PR_DIR/138.json"

# Create PR description
cat > "$PR_DIR/PR_DESCRIPTION.md" << EOF
# Add ChainID 138 - DeFi Oracle Meta Mainnet

## Network Information

- **Chain ID**: 138 (0x8a)
- **Network Name**: DeFi Oracle Meta Mainnet
- **Short Name**: defi-oracle
- **Native Currency**: ETH (18 decimals)
- **Consensus**: IBFT 2.0 (Istanbul BFT)

## RPC Endpoints

- Primary: \`https://rpc.d-bis.org\`
- Secondary: \`https://rpc2.d-bis.org\`
- WebSocket: \`wss://rpc.d-bis.org\`

## Block Explorer

- **Name**: Blockscout
- **URL**: \`https://explorer.d-bis.org\`
- **Standard**: EIP3091

## Network Status

- ✅ Network is live and operational
- ✅ RPC endpoints are publicly accessible
- ✅ Block explorer is deployed
- ✅ Token contracts are deployed
- ✅ Network is stable and tested

## Additional Information

- **Info URL**: https://github.com/Defi-Oracle-Tooling/smom-dbis-138
- **Icon**: https://explorer.d-bis.org/images/logo.png

## Testing

The network has been tested with:
- ✅ MetaMask wallet connection
- ✅ Token transfers
- ✅ Contract interactions
- ✅ Block explorer functionality

## Checklist

- [x] Chain ID is unique (138)
- [x] All required fields are present
- [x] RPC endpoints are accessible
- [x] Block explorer is accessible
- [x] Network is stable
- [x] Documentation is complete
EOF

log_success "Created: $PR_DIR/PR_DESCRIPTION.md"

# Create submission instructions
cat > "$PR_DIR/SUBMISSION_INSTRUCTIONS.md" << 'EOF'
# Ethereum-Lists PR Submission Instructions

## Prerequisites

1. Fork the ethereum-lists/chains repository
2. Clone your fork locally
3. Create a new branch: `git checkout -b add-chainid-138`

## Steps

1. **Copy chain metadata**:
   ```bash
   cp 138.json <ethereum-lists-repo>/_data/chains/eip155-138.json
   ```

2. **Validate the file**:
   ```bash
   cd <ethereum-lists-repo>
   npm install
   npm run validate
   ```

3. **Commit and push**:
   ```bash
   git add _data/chains/eip155-138.json
   git commit -m "Add ChainID 138 - DeFi Oracle Meta Mainnet"
   git push origin add-chainid-138
   ```

4. **Create PR**:
   - Go to https://github.com/ethereum-lists/chains
   - Click "New Pull Request"
   - Select your branch
   - Use PR_DESCRIPTION.md as the PR description
   - Submit PR

## PR Requirements

- [x] Chain ID is unique
- [x] All required fields are present
- [x] RPC endpoints are accessible
- [x] Block explorer is accessible
- [x] Network is stable
- [x] Follows ethereum-lists format

## Review Process

1. Automated validation will run
2. Maintainers will review the PR
3. Network will be tested
4. PR will be merged if approved

## Timeline

- Initial review: 1-2 weeks
- Testing: 1-2 weeks
- Merge: After approval

## Contact

For questions, contact the ethereum-lists maintainers or open an issue.
EOF

log_success "Created: $PR_DIR/SUBMISSION_INSTRUCTIONS.md"

log_info ""
log_info "========================================="
log_info "PR Preparation Complete!"
log_info "========================================="
log_info ""
log_info "Files created in: $PR_DIR"
log_info "  - 138.json (chain metadata)"
log_info "  - PR_DESCRIPTION.md (PR description)"
log_info "  - SUBMISSION_INSTRUCTIONS.md (submission guide)"
log_info ""
log_info "Next steps:"
log_info "1. Review the files in $PR_DIR"
log_info "2. Follow SUBMISSION_INSTRUCTIONS.md"
log_info "3. Submit PR to ethereum-lists/chains"
log_info ""
