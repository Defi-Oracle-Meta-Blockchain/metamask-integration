# MetaMask Oracle Integration Guide

**Date**: Mon Dec 22 00:17:03 PST 2025  
**ChainID**: 138  
**Oracle Address**: 0x3304b747e565a97ec8ac220b0b6a1f6ffdb837e6

---

## 📋 Overview

This guide explains how to integrate the deployed Oracle contract with MetaMask for ETH/USD price feeds.

---

## 🔗 Contract Information

- **Oracle Proxy Address**: `0x3304b747e565a97ec8ac220b0b6a1f6ffdb837e6`
- **ChainID**: 138
- **RPC Endpoint**: `https://rpc-core.d-bis.org`
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
   - **RPC URL**: `https://rpc-core.d-bis.org`
   - **Chain ID**: 138
   - **Currency Symbol**: ETH
   - **Block Explorer**: https://explorer.d-bis.org (optional)

### Method 2: Import Configuration

Use the configuration file: `docs/METAMASK_NETWORK_CONFIG.json`

---

## 💰 Reading Price from Oracle

### Using Web3.js

```javascript
const Web3 = require('web3');
const web3 = new Web3('https://rpc-core.d-bis.org');

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

const oracleAddress = '0x3304b747e565a97ec8ac220b0b6a1f6ffdb837e6';
const oracle = new web3.eth.Contract(oracleABI, oracleAddress);

// Get latest price
async function getPrice() {
  const result = await oracle.methods.latestRoundData().call();
  const price = result.answer / 1e8; // Convert from 8 decimals to USD
  console.log(`ETH/USD Price: $${price}`);
  return price;
}

getPrice();
```

### Using Ethers.js

```javascript
const { ethers } = require('ethers');

const provider = new ethers.providers.JsonRpcProvider('https://rpc-core.d-bis.org');

// Oracle Proxy ABI (simplified)
const oracleABI = [
  "function latestRoundData() external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)"
];

const oracleAddress = '0x3304b747e565a97ec8ac220b0b6a1f6ffdb837e6';
const oracle = new ethers.Contract(oracleAddress, oracleABI, provider);

// Get latest price
async function getPrice() {
  const result = await oracle.latestRoundData();
  const price = result.answer.toNumber() / 1e8; // Convert from 8 decimals to USD
  console.log(`ETH/USD Price: $${price}`);
  return price;
}

getPrice();
```

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

```bash
# Query latest round data
cast call 0x3304b747e565a97ec8ac220b0b6a1f6ffdb837e6 "latestRoundData()" --rpc-url https://rpc-core.d-bis.org
```

### Check Update Frequency

The Oracle should update every 60 seconds (heartbeat). Monitor the `updatedAt` timestamp to verify.

---

## 📚 Additional Resources

- Oracle Contract: `0x3304b747e565a97ec8ac220b0b6a1f6ffdb837e6`
- Network Config: `docs/METAMASK_NETWORK_CONFIG.json`
- Token List: `docs/METAMASK_TOKEN_LIST.json`

---

**Last Updated**: Mon Dec 22 00:17:03 PST 2025
