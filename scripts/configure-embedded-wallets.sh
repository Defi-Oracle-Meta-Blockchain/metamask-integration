#!/bin/bash

# Configure MetaMask Embedded Wallets for ChainID 138
# This script generates configuration for the MetaMask Embedded Wallets dashboard

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
log_info "MetaMask Embedded Wallets Configuration"
log_info "========================================="
log_info ""

# Create configuration directory
CONFIG_DIR="$PROJECT_ROOT/embedded-wallets-config"
mkdir -p "$CONFIG_DIR"

# Create network configuration
log_info "Creating network configuration..."
cat > "$CONFIG_DIR/network-config.json" << 'EOF'
{
  "chainId": 138,
  "chainIdHex": "0x8a",
  "chainName": "DeFi Oracle Meta Mainnet",
  "currencySymbol": "ETH",
  "currencyName": "Ether",
  "decimals": 18,
  "blockExplorerUrl": "https://explorer.d-bis.org",
  "namespace": "eip155",
  "rpcUrls": [
    "https://rpc.d-bis.org",
    "https://rpc2.d-bis.org"
  ],
  "isTestnet": false,
  "isMainnet": true
}
EOF

log_success "Created: $CONFIG_DIR/network-config.json"

# Create SDK configuration
log_info "Creating SDK configuration..."
cat > "$CONFIG_DIR/sdk-config.ts" << 'EOF'
// MetaMask Embedded Wallets SDK Configuration for ChainID 138
import { CHAIN_NAMESPACES } from '@web3auth/base';

export const CHAIN_138_CONFIG = {
  chainNamespace: CHAIN_NAMESPACES.EIP155,
  chainId: '0x8a', // 138 in hex
  rpcTarget: 'https://rpc.d-bis.org',
  displayName: 'DeFi Oracle Meta Mainnet',
  blockExplorerUrl: 'https://explorer.d-bis.org',
  ticker: 'ETH',
  tickerName: 'Ether',
  logo: 'https://explorer.d-bis.org/images/logo.png',
};

// Web3Auth Configuration
export const WEB3AUTH_CONFIG = {
  clientId: process.env.WEB3AUTH_CLIENT_ID || 'YOUR_CLIENT_ID',
  chainConfig: CHAIN_138_CONFIG,
  web3AuthNetwork: 'mainnet', // or 'testnet' for development
  uiConfig: {
    appName: 'DeFi Oracle Meta Mainnet',
    mode: 'auto', // 'light', 'dark', or 'auto'
    primaryColor: '#667eea',
    loginGridCol: 3,
    primaryButtonColor: '#667eea',
  },
};
EOF

log_success "Created: $CONFIG_DIR/sdk-config.ts"

# Create dashboard configuration guide
cat > "$CONFIG_DIR/DASHBOARD_CONFIGURATION.md" << 'EOF'
# MetaMask Embedded Wallets Dashboard Configuration

## Step-by-Step Configuration Guide

### 1. Create Project

1. Go to [MetaMask Developer Dashboard](https://dashboard.metamask.io)
2. Click "Create New Project"
3. Enter project name: "ChainID 138 Integration"
4. Select project type: "Embedded Wallets"
5. Click "Create"

### 2. Configure ChainID 138 Network

Navigate to **Configuration → Chains and Networks**:

1. Click "Add Custom Network"
2. Enter the following:

   **Chain ID**: `138`
   
   **Currency Symbol**: `ETH`
   
   **Block Explorer URL**: `https://explorer.d-bis.org`
   
   **Namespace**: `eip155`
   
   **RPC URL**: `https://rpc.d-bis.org`

3. Click "Save"
4. Toggle network to "Enabled"
5. Mark as "Mainnet" (not testnet)

### 3. Configure Branding

Navigate to **Configuration → Customization → Branding**:

1. **Upload Logo**:
   - Upload ChainID 138 network logo
   - Recommended: 512x512px PNG
   - Enable "Use logo as loader"

2. **Application Name**: "DeFi Oracle Meta Mainnet"

3. **Terms and Privacy**:
   - Add Terms of Service URL (if available)
   - Add Privacy Policy URL (if available)

4. **Default Language**: English

### 4. Configure Theme

Navigate to **Configuration → Customization → Theme and Colors**:

1. **Select Mode**: Auto (adapts to user preference)

2. **Primary Color**: `#667eea` (or your brand color)

3. **On Primary Color**: `#ffffff` (white text on primary)

### 5. Configure Login Modal

Navigate to **Configuration → Customization → Login Modal**:

1. **Design**:
   - **Modal Appearance**: Modal Widget (pop-up)
   - **Logo Alignment**: Center
   - **Border Radius**: Medium
   - **Border Radius Type**: Rounded

2. **Authentication Order**:
   - Arrange login methods (drag and drop)
   - Recommended order:
     1. External Wallets (MetaMask, WalletConnect)
     2. Social Logins (Google, Twitter)
     3. Email/Phone

3. **External Wallets**:
   - Enable "Show installed external wallets"
   - Set number of wallets to display: 3-5

### 6. Add Token List

Navigate to **Configuration → Chains and Networks → ChainID 138**:

1. **Token List URL**: Add your hosted token list URL
   - Example: `https://your-domain.com/token-list.json`
   - Or: `https://ipfs.io/ipfs/YOUR_HASH`

2. **Verify Tokens**: Check that tokens appear correctly

### 7. Save and Publish

1. Review all configurations
2. Click "Save & Publish"
3. Changes take effect immediately

### 8. Get Client ID

1. Navigate to **Project Settings**
2. Copy your **Client ID**
3. Use in SDK configuration

---

## Configuration Values Summary

| Setting | Value |
|---------|-------|
| Chain ID | 138 (0x8a) |
| Chain Name | DeFi Oracle Meta Mainnet |
| Currency Symbol | ETH |
| RPC URL | https://rpc.d-bis.org |
| Block Explorer | https://explorer.d-bis.org |
| Namespace | eip155 |
| Network Type | Mainnet |

---

## Testing

After configuration:

1. **Test Network Addition**: Verify ChainID 138 appears in network list
2. **Test Connection**: Connect wallet using embedded wallet
3. **Test Token Display**: Verify tokens appear correctly
4. **Test Transactions**: Send test transaction

---

## Troubleshooting

### Network Not Appearing

- Verify Chain ID is correct (138)
- Check RPC URL is accessible
- Ensure network is enabled in dashboard

### Tokens Not Displaying

- Verify token list URL is accessible
- Check token list format is correct
- Ensure tokens have correct ChainID (138)

### Connection Issues

- Verify Client ID is correct
- Check SDK configuration matches dashboard
- Review browser console for errors

---

**Last Updated**: 2026-01-26
EOF

log_success "Created: $CONFIG_DIR/DASHBOARD_CONFIGURATION.md"

log_info ""
log_info "========================================="
log_info "Embedded Wallets Config Complete!"
log_info "========================================="
log_info ""
log_info "Files created in: $CONFIG_DIR"
log_info "  - network-config.json (network config)"
log_info "  - sdk-config.ts (SDK configuration)"
log_info "  - DASHBOARD_CONFIGURATION.md (setup guide)"
log_info ""
log_info "Next steps:"
log_info "1. Review DASHBOARD_CONFIGURATION.md"
log_info "2. Configure dashboard with provided values"
log_info "3. Get Client ID from dashboard"
log_info "4. Integrate SDK in your dApp"
log_info ""
