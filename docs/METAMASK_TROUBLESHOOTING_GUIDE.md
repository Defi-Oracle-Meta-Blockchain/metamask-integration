# MetaMask Troubleshooting Guide - ChainID 138

**Date**: $(date)  
**Network**: SMOM-DBIS-138 (ChainID 138)

---

## 🔍 Common Issues & Solutions

### 1. Network Connection Issues

#### Issue: "Network Error" or "Failed to Connect"

**Symptoms**:
- MetaMask shows "Network Error"
- Can't fetch balance
- Transactions fail immediately

**Solutions**:

1. **Verify RPC URL**
   ```
   Correct: https://rpc-core.d-bis.org
   Incorrect: http://rpc-core.d-bis.org (missing 's')
   ```

2. **Check Chain ID**
   - Must be exactly `138` (decimal)
   - Not `0x8a` (that's hex, but MetaMask expects decimal in manual entry)
   - Verify in network settings

3. **Remove and Re-add Network**
   - Settings → Networks → Remove "SMOM-DBIS-138"
   - Add network again with correct settings
   - See [Quick Start Guide](./METAMASK_QUICK_START_GUIDE.md)

4. **Clear MetaMask Cache**
   - Settings → Advanced → Reset Account (if needed)
   - Or clear browser cache and reload MetaMask

5. **Check RPC Endpoint Status**
   ```bash
   curl -X POST https://rpc-core.d-bis.org \
     -H "Content-Type: application/json" \
     -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'
   ```

---

### 2. Token Display Issues

#### Issue: "6,000,000,000.0T WETH" Instead of "6 WETH"

**Root Cause**: WETH9 contract's `decimals()` returns 0 instead of 18

**Solution**:

1. **Remove Token**
   - Find WETH9 in token list
   - Click token → "Hide token" or remove

2. **Re-import with Correct Decimals**
   - Import tokens → Custom token
   - Address: `0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2`
   - Symbol: `WETH`
   - **Decimals: `18`** ⚠️ **Critical: Must be 18**

3. **Verify Display**
   - Should now show: "6 WETH" or "6.0 WETH"
   - Not: "6,000,000,000.0T WETH"

**See**: [WETH9 Display Fix Instructions](./METAMASK_WETH9_FIX_INSTRUCTIONS.md)

---

#### Issue: Token Not Showing Balance

**Symptoms**:
- Token imported but shows 0 balance
- Token doesn't appear in list

**Solutions**:

1. **Check Token Address**
   - WETH9: `0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2`
   - WETH10: `0xf4BB2e28688e89fCcE3c0580D37d36A7672E8A9f`
   - Verify address is correct (case-sensitive)

2. **Verify You Have Tokens**
   ```bash
   cast call 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2 \
     "balanceOf(address)" <YOUR_ADDRESS> \
     --rpc-url https://rpc-core.d-bis.org
   ```

3. **Refresh Token List**
   - Click "Import tokens" → Refresh
   - Or remove and re-add token

4. **Check Network**
   - Ensure you're on ChainID 138
   - Tokens are chain-specific

---

### 3. Transaction Issues

#### Issue: Transaction Stuck or Pending Forever

**Symptoms**:
- Transaction shows "Pending" for extended time
- No confirmation after hours

**Solutions**:

1. **Check Network Status**
   - Verify RPC endpoint is responding
   - Check block explorer for recent blocks

2. **Check Gas Price**
   - May need to increase gas price
   - Network may be congested

3. **Replace Transaction** (Same Nonce)
   - Create new transaction with same nonce
   - Higher gas price
   - This cancels the old transaction

4. **Reset Nonce** (Last Resort)
   - Settings → Advanced → Reset Account
   - ⚠️ This clears transaction history

---

#### Issue: "Insufficient Funds for Gas"

**Symptoms**:
- Transaction fails immediately
- Error: "insufficient funds"

**Solutions**:

1. **Check ETH Balance**
   - Need ETH for gas fees
   - Gas costs vary (typically 0.001-0.01 ETH)

2. **Reduce Gas Limit** (If too high)
   - MetaMask may estimate too high
   - Try manual gas limit

3. **Get More ETH**
   - Request from network administrators
   - Bridge from another chain
   - Use faucet (if available)

---

#### Issue: Transaction Reverted

**Symptoms**:
- Transaction confirmed but reverted
- Error in transaction details

**Solutions**:

1. **Check Transaction Details**
   - View on block explorer
   - Look for revert reason

2. **Common Revert Reasons**:
   - Insufficient allowance (for token transfers)
   - Contract logic error
   - Invalid parameters
   - Out of gas (rare, usually fails before)

3. **Verify Contract State**
   - Check if contract is paused
   - Verify you have permissions
   - Check contract requirements

---

### 4. Price Feed Issues

#### Issue: Price Not Updating

**Symptoms**:
- Oracle price seems stale
- Price doesn't change

**Solutions**:

1. **Check Oracle Contract**
   ```bash
   cast call 0x3304b747e565a97ec8ac220b0b6a1f6ffdb837e6 \
     "latestRoundData()" \
     --rpc-url https://rpc-core.d-bis.org
   ```

2. **Verify `updatedAt` Timestamp**
   - Should update every 60 seconds
   - If > 5 minutes old, Oracle Publisher may be down

3. **Check Oracle Publisher Service**
   - Service should be running (VMID 3500)
   - Check service logs for errors

4. **Manual Price Query**
   - Use Web3.js or Ethers.js to query directly
   - See [Oracle Integration Guide](./METAMASK_ORACLE_INTEGRATION.md)

---

#### Issue: Price Returns Zero or Error

**Symptoms**:
- `latestRoundData()` returns 0
- Contract call fails

**Solutions**:

1. **Verify Contract Address**
   - Oracle Proxy: `0x3304b747e565a97ec8ac220b0b6a1f6ffdb837e6`
   - Ensure correct address

2. **Check Contract Deployment**
   - Verify contract exists on ChainID 138
   - Check block explorer

3. **Verify Network**
   - Must be on ChainID 138
   - Price feeds are chain-specific

---

### 5. Network Switching Issues

#### Issue: Can't Switch to ChainID 138

**Symptoms**:
- Network doesn't appear in list
- Switch fails

**Solutions**:

1. **Add Network Manually**
   - See [Quick Start Guide](./METAMASK_QUICK_START_GUIDE.md)
   - Ensure all fields are correct

2. **Programmatic Addition** (For dApps)
   ```javascript
   try {
     await window.ethereum.request({
       method: 'wallet_switchEthereumChain',
       params: [{ chainId: '0x8a' }], // 138 in hex
     });
   } catch (switchError) {
     // Network doesn't exist, add it
     if (switchError.code === 4902) {
       await window.ethereum.request({
         method: 'wallet_addEthereumChain',
         params: [networkConfig],
       });
     }
   }
   ```

3. **Clear Network Cache**
   - Remove network
   - Re-add with correct settings

---

### 6. Account Issues

#### Issue: Wrong Account Connected

**Symptoms**:
- Different address than expected
- Can't see expected balance

**Solutions**:

1. **Switch Account in MetaMask**
   - Click account icon
   - Select correct account

2. **Import Account** (If needed)
   - Settings → Import Account
   - Use private key or seed phrase

3. **Verify Address**
   - Check address matches expected
   - Addresses are case-insensitive but verify format

---

#### Issue: Account Not Showing Balance

**Symptoms**:
- Account connected but balance is 0
- Expected to have ETH/tokens

**Solutions**:

1. **Verify Network**
   - Must be on ChainID 138
   - Balances are chain-specific

2. **Check Address**
   - Verify correct address
   - Check on block explorer

3. **Refresh Balance**
   - Click refresh icon in MetaMask
   - Or switch networks and switch back

---

## 🔧 Advanced Troubleshooting

### Enable Debug Mode

**MetaMask Settings**:
1. Settings → Advanced
2. Enable "Show Hex Data"
3. Enable "Enhanced Gas Fee UI"
4. Check browser console for errors

### Check Browser Console

**Open Console**:
- Chrome/Edge: F12 → Console
- Firefox: F12 → Console
- Safari: Cmd+Option+I → Console

**Look For**:
- RPC errors
- Network errors
- JavaScript errors
- MetaMask-specific errors

### Verify RPC Response

**Test RPC Endpoint**:
```bash
curl -X POST https://rpc-core.d-bis.org \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "eth_blockNumber",
    "params": [],
    "id": 1
  }'
```

**Expected Response**:
```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": "0x..."
}
```

---

## 📞 Getting Help

### Resources

1. **Documentation**:
   - [Quick Start Guide](./METAMASK_QUICK_START_GUIDE.md)
   - [Full Integration Requirements](./METAMASK_FULL_INTEGRATION_REQUIREMENTS.md)
   - [Oracle Integration](./METAMASK_ORACLE_INTEGRATION.md)

2. **Block Explorer**:
   - `https://explorer.d-bis.org`
   - Check transactions, contracts, addresses

3. **Network Status**:
   - RPC: `https://rpc-core.d-bis.org`
   - Verify endpoint is responding

### Information to Provide When Reporting Issues

1. **MetaMask Version**: Settings → About
2. **Browser**: Chrome/Firefox/Safari + version
3. **Network**: ChainID 138
4. **Error Message**: Exact error text
5. **Steps to Reproduce**: What you did before error
6. **Console Errors**: Any JavaScript errors
7. **Transaction Hash**: If transaction-related

---

## ✅ Quick Diagnostic Checklist

Run through this checklist when troubleshooting:

- [ ] Network is "SMOM-DBIS-138" (ChainID 138)
- [ ] RPC URL is `https://rpc-core.d-bis.org`
- [ ] Chain ID is `138` (decimal, not hex)
- [ ] Account is connected and correct
- [ ] Sufficient ETH for gas fees
- [ ] Token decimals are correct (18 for WETH)
- [ ] Browser console shows no errors
- [ ] RPC endpoint is responding
- [ ] Block explorer shows recent blocks

---

**Last Updated**: $(date)

