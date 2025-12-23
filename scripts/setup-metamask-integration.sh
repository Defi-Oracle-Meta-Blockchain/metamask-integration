#!/usr/bin/env bash
# Set up MetaMask integration for ChainID 138 with Oracle price feeds
# Usage: ./setup-metamask-integration.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Contract addresses
ORACLE_PROXY="0x3304b747e565a97ec8ac220b0b6a1f6ffdb837e6"
RPC_URL="https://rpc-core.d-bis.org"
CHAIN_ID="138"

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

log_info "========================================="
log_info "MetaMask Integration Setup"
log_info "========================================="
log_info ""

# Create MetaMask network configuration
log_info "Creating MetaMask network configuration..."

cat > "$PROJECT_ROOT/docs/METAMASK_NETWORK_CONFIG.json" <<EOF
{
  "chainId": "0x8a",
  "chainName": "SMOM-DBIS-138",
  "rpcUrls": [
    "$RPC_URL"
  ],
  "nativeCurrency": {
    "name": "Ether",
    "symbol": "ETH",
    "decimals": 18
  },
  "blockExplorerUrls": [
    "https://explorer.d-bis.org"
  ],
  "iconUrls": [
    "https://raw.githubusercontent.com/ethereum/ethereum.org/main/static/images/eth-diamond-black.png"
  ]
}
EOF

log_success "MetaMask network configuration created"

# Create token list for MetaMask
log_info "Creating token list with Oracle price feed..."

cat > "$PROJECT_ROOT/docs/METAMASK_TOKEN_LIST.json" <<EOF
{
  "name": "SMOM-DBIS-138 Token List",
  "version": {
    "major": 1,
    "minor": 0,
    "patch": 0
  },
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%S.000Z)",
  "tokens": [
    {
      "chainId": 138,
      "address": "$ORACLE_PROXY",
      "name": "ETH/USD Price Feed",
      "symbol": "ETH-USD",
      "decimals": 8,
      "logoURI": "https://raw.githubusercontent.com/ethereum/ethereum.org/main/static/images/eth-diamond-black.png"
    }
  ]
}
EOF

log_success "Token list created"

# Create Oracle integration guide
log_info "Creating Oracle integration guide..."

cat > "$PROJECT_ROOT/docs/METAMASK_ORACLE_INTEGRATION.md" <<EOF
# MetaMask Oracle Integration Guide

**Date**: $(date)  
**ChainID**: 138  
**Oracle Address**: $ORACLE_PROXY

---

## 📋 Overview

This guide explains how to integrate the deployed Oracle contract with MetaMask for ETH/USD price feeds.

---

## 🔗 Contract Information

- **Oracle Proxy Address**: \`$ORACLE_PROXY\`
- **ChainID**: 138
- **RPC Endpoint**: \`$RPC_URL\`
- **Price Feed**: ETH/USD
- **Decimals**: 8
- **Update Frequency**: 60 seconds (heartbeat)

---

## 📝 MetaMask Network Configuration

### Method 1: Manual Configuration

1. Open MetaMask
2. Click network dropdown → "Add Network" → "Add a network manually"
3. Enter the following:
   - **Network Name**: SMOM-DBIS-138
   - **RPC URL**: \`$RPC_URL\`
   - **Chain ID**: 138
   - **Currency Symbol**: ETH
   - **Block Explorer**: https://explorer.d-bis.org (optional)

### Method 2: Import Configuration

Use the configuration file: \`docs/METAMASK_NETWORK_CONFIG.json\`

---

## 💰 Reading Price from Oracle

### Using Web3.js

\`\`\`javascript
const Web3 = require('web3');
const web3 = new Web3('$RPC_URL');

// Oracle Proxy ABI (simplified)
const oracleABI = [
  {
    "inputs": [],
    "name": "latestRoundData",
    "outputs": [
      {"name": "roundId", "type": "uint80"},
      {"name": "answer", "type": "int256"},
      {"name": "startedAt", "type": "uint256"},
      {"name": "updatedAt", "type": "uint256"},
      {"name": "answeredInRound", "type": "uint80"}
    ],
    "stateMutability": "view",
    "type": "function"
  }
];

const oracleAddress = '$ORACLE_PROXY';
const oracle = new web3.eth.Contract(oracleABI, oracleAddress);

// Get latest price
async function getPrice() {
  const result = await oracle.methods.latestRoundData().call();
  const price = result.answer / 1e8; // Convert from 8 decimals to USD
  console.log(\`ETH/USD Price: $\${price}\`);
  return price;
}

getPrice();
\`\`\`

### Using Ethers.js

\`\`\`javascript
const { ethers } = require('ethers');

const provider = new ethers.providers.JsonRpcProvider('$RPC_URL');

// Oracle Proxy ABI (simplified)
const oracleABI = [
  "function latestRoundData() external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)"
];

const oracleAddress = '$ORACLE_PROXY';
const oracle = new ethers.Contract(oracleAddress, oracleABI, provider);

// Get latest price
async function getPrice() {
  const result = await oracle.latestRoundData();
  const price = result.answer.toNumber() / 1e8; // Convert from 8 decimals to USD
  console.log(\`ETH/USD Price: $\${price}\`);
  return price;
}

getPrice();
\`\`\`

---

## 🔄 Oracle Publisher Service

The Oracle Publisher service (VMID 3500) automatically updates the Oracle contract with price feeds.

**Configuration**:
- **Service**: Oracle Publisher
- **VMID**: 3500
- **Update Interval**: 60 seconds
- **Price Source**: External API (e.g., CoinGecko, CoinMarketCap)

---

## ✅ Verification

### Check Oracle is Updating

\`\`\`bash
# Query latest round data
cast call $ORACLE_PROXY "latestRoundData()" --rpc-url $RPC_URL
\`\`\`

### Check Update Frequency

The Oracle should update every 60 seconds (heartbeat). Monitor the \`updatedAt\` timestamp to verify.

---

## 📚 Additional Resources

- Oracle Contract: \`$ORACLE_PROXY\`
- Network Config: \`docs/METAMASK_NETWORK_CONFIG.json\`
- Token List: \`docs/METAMASK_TOKEN_LIST.json\`

---

**Last Updated**: $(date)
EOF

log_success "Oracle integration guide created"

log_info ""
log_success "========================================="
log_success "MetaMask Integration Setup Complete!"
log_success "========================================="
log_info ""
log_info "Created files:"
log_info "  - docs/METAMASK_NETWORK_CONFIG.json"
log_info "  - docs/METAMASK_TOKEN_LIST.json"
log_info "  - docs/METAMASK_ORACLE_INTEGRATION.md"
log_info ""
log_info "Next steps:"
log_info "1. Add network to MetaMask using the configuration file"
log_info "2. Verify Oracle Publisher service is updating prices"
log_info "3. Test reading price from Oracle contract"
log_info ""

