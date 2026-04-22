# MetaMask WETH9 Display Fix Instructions

**Date**: $(date)  
**Issue**: MetaMask showing "6,000,000,000.0T WETH" instead of "6 WETH"  
**Root Cause**: WETH9 contract's `decimals()` returns 0 instead of 18

---

## 🔍 Problem Confirmed

**Root Cause**: The WETH9 contract at `0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2` has a `decimals()` function that returns `0x0` instead of `18`.

When MetaMask reads the token balance:
- It gets: `6,000,000,000,000,000,000` wei (raw value)
- It expects: `decimals = 18` to format correctly
- It gets: `decimals = 0` (incorrect)
- Result: Displays as `6,000,000,000.0T WETH` ❌

**Actual Balance**: 6 WETH ✅

---

## ✅ Solution: Manual Token Import in MetaMask

Since the contract's `decimals()` function is incorrect, you need to manually specify the correct decimals when importing the token.

### Step-by-Step Instructions

1. **Open MetaMask**
   - Make sure you're connected to "DeFi Oracle Meta Mainnet" (ChainID 138)

2. **Go to Import Tokens**
   - Click on the token list (where you see "Wrapped Ether")
   - Scroll down and click "Import tokens"
   - Or go to: Settings → Tokens → Import tokens

3. **Enter Token Details**
   - **Token Contract Address**: `0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2`
   - **Token Symbol**: `WETH`
   - **Decimals of Precision**: `18` ⚠️ **IMPORTANT: Set this to 18**
   - Click "Add Custom Token"

4. **Verify**
   - The token should now display as "6 WETH" instead of "6,000,000,000.0T WETH"
   - **Note:** MetaMask only lets you **hide** an asset, not remove it. If WETH already shows the wrong amount (e.g. "500.00T WETH"): open the asset → ⋮ menu → **Hide WETH**, then add the token again via the explorer’s "Add to wallet" button or manual import above with **Decimals: 18**. The new entry will use the correct decimals.

---

## 📱 MetaMask: Hide, then re-add with correct decimals

MetaMask does not offer "Remove token" — only **Hide [asset]** (⋮ menu on the token). To fix a wrong WETH display (e.g. "500.00T WETH" instead of "500 WETH"):

1. Open the WETH asset → tap the **⋮** menu → **Hide WETH**.
2. Add the token again so MetaMask gets **decimals: 18**:
   - **Option A:** Go to https://explorer.d-bis.org/weth , connect MetaMask, and click the **wallet icon** next to the WETH9 contract. Confirm "Add token." The explorer sends decimals 18 and symbol WETH.
   - **Option B:** In MetaMask, Import tokens → Custom token: Address `0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2`, Symbol **WETH**, **Decimals 18** → Add.

The (re-)added token should then show the correct balance (e.g. 500 WETH).

---

## 🔄 Alternative: Use Token List

If you have access to host a token list JSON file:

1. **Use the Updated Token List**
   - File: `docs/METAMASK_TOKEN_LIST.json`
   - Now includes WETH9 with correct decimals (18)

2. **Host the Token List**
   - Upload to GitHub, IPFS, or any public URL
   - Example: `https://your-domain.com/token-list.json`

3. **Add to MetaMask**
   - Settings → Security & Privacy → Token Lists
   - Add custom token list URL
   - Or import directly in dApp

---

## 🌐 Explorer "Add to wallet" (same as MetaMask display)

The **SolaceScanScout explorer** (https://explorer.d-bis.org) adds WETH9 and WETH10 to MetaMask with **decimals: 18** and **symbol: WETH** when you click the wallet icon next to a token (WETH page, Tokens list, or token detail). So MetaMask will display balances the same way as the explorer (e.g. "100 WETH", not "100T" or raw wei).

- **WETH page** (Tools → WETH): wallet icon next to each contract address.
- **Tokens list** and **token detail**: wallet icon to add that token with correct decimals and symbol.

Our token lists (`METAMASK_TOKEN_LIST.json`, `config/token-list.json`, provider token list) also use **symbol: WETH** and **decimals: 18** for both WETH9 and WETH10 so any app using these lists will show the same as the explorer.

---

## 📊 Verification

After fixing, verify the display:

1. **Check Balance Display**
   - Should show: `6 WETH` or `6.0 WETH` ✅
   - Should NOT show: `6,000,000,000.0T WETH` ❌

2. **Verify On-Chain Balance** (Optional)
   ```bash
   cast call 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2 \
     "balanceOf(address)" <YOUR_ADDRESS> \
     --rpc-url http://192.168.11.250:8545 | \
     xargs -I {} cast --to-unit {} ether
   # Should output: 6
   ```

---

## 🐛 Why This Happens

### WETH9 Contract Issue

The WETH9 contract is an older implementation that:
- ✅ Implements ERC-20 `balanceOf()`, `transfer()`, etc.
- ❌ Does NOT properly implement `decimals()` (returns 0)
- ❌ May not implement other ERC-20 optional functions

### MetaMask Behavior

When MetaMask encounters a token with `decimals = 0`:
1. It reads the raw balance: `6000000000000000000`
2. Without proper decimals, it doesn't know to divide by 10¹⁸
3. It formats the number incorrectly
4. Result: `6,000,000,000.0T` (treating it as a very large number)

---

## ✅ Expected Result

After applying the fix:
- **Before**: `6,000,000,000.0T WETH` ❌
- **After**: `6 WETH` or `6.0 WETH` ✅

---

## 📝 Notes

- This is a **display issue only** - your actual balance is correct on-chain
- Transactions will work correctly regardless of the display
- The fix only affects how MetaMask displays the balance
- Other wallets may have the same issue if they rely on `decimals()`

---

## 🔗 Related Documentation

- [MetaMask WETH9 Display Bug Analysis](./METAMASK_WETH9_DISPLAY_BUG.md)
- [WETH9 Creation Analysis](./WETH9_CREATION_ANALYSIS.md)
- [MetaMask Token List](./METAMASK_TOKEN_LIST.json)

---

**Last Updated**: $(date)

