# MetaMask Quick Start Guide - ChainID 138

**Date**: $(date)  
**Network**: SMOM-DBIS-138 (ChainID 138)  
**Purpose**: Get started with MetaMask on ChainID 138 in 5 minutes

---

## 🚀 Quick Start (5 Minutes)

### Step 1: Add Network to MetaMask

**Option A: Manual Addition** (Recommended for first-time users)

1. Open MetaMask extension
2. Click network dropdown (top of MetaMask)
3. Click "Add Network" → "Add a network manually"
4. Enter the following:
   - **Network Name**: `SMOM-DBIS-138`
   - **RPC URL**: `https://rpc-core.d-bis.org`
   - **Chain ID**: `138`
   - **Currency Symbol**: `ETH`
   - **Block Explorer URL**: `https://explorer.d-bis.org` (optional)
5. Click "Save"

**Option B: Programmatic Addition** (For dApps)

If you're building a dApp, you can add the network programmatically:

```javascript
await window.ethereum.request({
  method: 'wallet_addEthereumChain',
  params: [{
    chainId: '0x8a', // 138 in hex
    chainName: 'SMOM-DBIS-138',
    nativeCurrency: {
      name: 'Ether',
      symbol: 'ETH',
      decimals: 18
    },
    rpcUrls: ['https://rpc-core.d-bis.org'],
    blockExplorerUrls: ['https://explorer.d-bis.org']
  }]
});
```

---

### Step 2: Import Tokens

**WETH9 (Wrapped Ether)**

1. In MetaMask, click "Import tokens"
2. Enter:
   - **Token Contract Address**: `0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2`
   - **Token Symbol**: `WETH`
   - **Decimals of Precision**: `18` ⚠️ **Important: Must be 18**
3. Click "Add Custom Token"

**WETH10 (Wrapped Ether v10)**

1. Click "Import tokens" again
2. Enter:
   - **Token Contract Address**: `0xf4BB2e28688e89fCcE3c0580D37d36A7672E8A9f`
   - **Token Symbol**: `WETH10`
   - **Decimals of Precision**: `18`
3. Click "Add Custom Token"

**Note**: If you see incorrect balances (like "6,000,000,000.0T"), ensure decimals are set to 18. See [WETH9 Display Fix](./METAMASK_WETH9_FIX_INSTRUCTIONS.md) for details.

---

### Step 3: Get Test ETH

**For Testing Purposes**:

If you need test ETH on ChainID 138:
1. Contact network administrators
2. Use a faucet (if available)
3. Bridge from another chain (if configured)

**Current Network Status**:
- ✅ Network: Operational
- ✅ RPC: `https://rpc-core.d-bis.org`
- ✅ Explorer: `https://explorer.d-bis.org`

---

### Step 4: Verify Connection

**Check Network**:
1. In MetaMask, verify you're on "SMOM-DBIS-138"
2. Check your ETH balance (should display correctly)
3. Verify token balances (WETH, WETH10)

**Test Transaction** (Optional):
1. Send a small amount of ETH to another address
2. Verify transaction appears in block explorer
3. Confirm balance updates

---

## 📊 Reading Price Feeds

### Get ETH/USD Price

**Oracle Contract**: `0x3304b747e565a97ec8ac220b0b6a1f6ffdb837e6`

**Using Web3.js**:
```javascript
const Web3 = require('web3');
const web3 = new Web3('https://rpc-core.d-bis.org');

const oracleABI = [{
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
}];

const oracle = new web3.eth.Contract(oracleABI, '0x3304b747e565a97ec8ac220b0b6a1f6ffdb837e6');

async function getPrice() {
  const result = await oracle.methods.latestRoundData().call();
  const price = result.answer / 1e8; // Convert from 8 decimals
  console.log(`ETH/USD: $${price}`);
  return price;
}

getPrice();
```

**Using Ethers.js**:
```javascript
const { ethers } = require('ethers');
const provider = new ethers.providers.JsonRpcProvider('https://rpc-core.d-bis.org');

const oracleABI = [
  "function latestRoundData() external view returns (uint80, int256, uint256, uint256, uint80)"
];

const oracle = new ethers.Contract(
  '0x3304b747e565a97ec8ac220b0b6a1f6ffdb837e6',
  oracleABI,
  provider
);

async function getPrice() {
  const result = await oracle.latestRoundData();
  const price = result.answer.toNumber() / 1e8;
  console.log(`ETH/USD: $${price}`);
  return price;
}

getPrice();
```

---

## 🔧 Common Tasks

### Send ETH

1. Click "Send" in MetaMask
2. Enter recipient address
3. Enter amount
4. Review gas fees
5. Confirm transaction

### Wrap ETH to WETH9

1. Go to WETH9 contract: `0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2`
2. Call `deposit()` function
3. Send ETH amount with transaction
4. Receive WETH9 tokens

### Check Transaction Status

1. Copy transaction hash from MetaMask
2. Visit: `https://explorer.d-bis.org/tx/<tx-hash>`
3. View transaction details, gas used, status

---

## ⚠️ Troubleshooting

### Network Not Connecting

**Issue**: Can't connect to network

**Solutions**:
1. Verify RPC URL: `https://rpc-core.d-bis.org`
2. Check Chain ID: Must be `138` (not 0x8a in decimal)
3. Try removing and re-adding network
4. Clear MetaMask cache and reload

### Token Balance Display Incorrect

**Issue**: Shows "6,000,000,000.0T WETH" instead of "6 WETH"

**Solution**: 
- Remove token from MetaMask
- Re-import with decimals set to `18`
- See [WETH9 Display Fix](./METAMASK_WETH9_FIX_INSTRUCTIONS.md) for details

### Price Feed Not Updating

**Issue**: Oracle price seems stale

**Solutions**:
1. Check Oracle contract: `0x3304b747e565a97ec8ac220b0b6a1f6ffdb837e6`
2. Verify `updatedAt` timestamp is recent (within 60 seconds)
3. Check Oracle Publisher service status

### Transaction Failing

**Issue**: Transactions not going through

**Solutions**:
1. Check you have sufficient ETH for gas
2. Verify network is selected correctly
3. Check transaction nonce (may need to reset)
4. Increase gas limit if needed

---

## 📚 Additional Resources

- [Full Integration Requirements](./METAMASK_FULL_INTEGRATION_REQUIREMENTS.md)
- [Oracle Integration Guide](./METAMASK_ORACLE_INTEGRATION.md)
- [WETH9 Display Bug Fix](./METAMASK_WETH9_FIX_INSTRUCTIONS.md)
- [Contract Addresses Reference](./CONTRACT_ADDRESSES_REFERENCE.md)

---

## ✅ Verification Checklist

After setup, verify:

- [ ] Network "SMOM-DBIS-138" appears in MetaMask
- [ ] Can switch to ChainID 138 network
- [ ] ETH balance displays correctly
- [ ] WETH9 token imported with correct decimals (18)
- [ ] WETH10 token imported with correct decimals (18)
- [ ] Can read price from Oracle contract
- [ ] Can send test transaction
- [ ] Transaction appears in block explorer

---

## 🎯 Next Steps

1. **Explore dApps**: Connect to dApps built on ChainID 138
2. **Bridge Assets**: Use CCIP bridges to transfer assets cross-chain
3. **Deploy Contracts**: Deploy your own smart contracts
4. **Build dApps**: Create applications using the network

---

**Last Updated**: $(date)

