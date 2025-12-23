# GitHub Pages Setup for Token List

**Date**: $(date)  
**Repository**: [Defi-Oracle-Meta-Blockchain/metamask-integration](https://github.com/Defi-Oracle-Meta-Blockchain/metamask-integration)  
**Purpose**: Enable GitHub Pages to host the MetaMask token list

---

## 🚀 Quick Setup

### Step 1: Enable GitHub Pages

1. Go to repository Settings
2. Navigate to **Pages** (left sidebar)
3. Under **Build and deployment** → **Source**:
   - Select **Branch**: `main`
   - Select **Folder**: `/ (root)` or `/docs`
   - Click **Save**

### Step 2: Verify Token List Location

The token list is located at:
- **Path**: `config/token-list.json`
- **URL after Pages enabled**: 
  - If root: `https://defi-oracle-meta-blockchain.github.io/metamask-integration/config/token-list.json`
  - If /docs: `https://defi-oracle-meta-blockchain.github.io/metamask-integration/config/token-list.json` (same)

### Step 3: Wait for Deployment

- GitHub Pages typically deploys within 1-2 minutes
- Check deployment status in **Actions** tab
- Green checkmark = deployed successfully

---

## 📋 Configuration Options

### Option 1: Root Directory (Recommended)

**Settings**:
- Branch: `main`
- Folder: `/ (root)`

**Token List URL**:
```
https://defi-oracle-meta-blockchain.github.io/metamask-integration/config/token-list.json
```

**Pros**:
- Simple structure
- Direct access to all files
- Works immediately

### Option 2: /docs Directory

**Settings**:
- Branch: `main`
- Folder: `/docs`

**Note**: If using /docs, you may need to move `config/token-list.json` to `docs/config/token-list.json` or create a symlink.

**Pros**:
- Keeps source files separate
- Standard GitHub Pages structure

---

## ✅ Verification

### Test Token List URL

After enabling Pages, test the URL:

```bash
curl -I https://defi-oracle-meta-blockchain.github.io/metamask-integration/config/token-list.json
```

**Expected Response**:
```
HTTP/2 200
Content-Type: application/json
```

### Validate JSON

```bash
curl https://defi-oracle-meta-blockchain.github.io/metamask-integration/config/token-list.json | jq .
```

Should return valid JSON without errors.

---

## 🔧 Adding to MetaMask

Once GitHub Pages is enabled and the token list is accessible:

1. Open MetaMask
2. Go to **Settings** → **Security & Privacy** → **Token Lists**
3. Click **Add custom token list**
4. Enter URL:
   ```
   https://defi-oracle-meta-blockchain.github.io/metamask-integration/config/token-list.json
   ```
5. Click **Add**

MetaMask will automatically import all tokens from the list.

---

## 📝 CORS Headers

GitHub Pages automatically sets proper CORS headers for JSON files, so no additional configuration is needed.

---

## 🔄 Updating the Token List

When you update `config/token-list.json`:

1. Commit changes to `main` branch
2. Push to GitHub
3. GitHub Pages automatically rebuilds (1-2 minutes)
4. New version is immediately available

**Note**: Update the `version` field in the token list JSON when making changes.

---

## 🎯 Current Token List

**File**: `config/token-list.json`

**Tokens Included**:
- ETH/USD Price Feed (`0x3304b747e565a97ec8ac220b0b6a1f6ffdb837e6`)
- WETH9 (`0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2`)
- WETH10 (`0xf4BB2e28688e89fCcE3c0580D37d36A7672E8A9f`)

---

## ✅ Checklist

- [ ] Enable GitHub Pages in repository settings
- [ ] Select branch: `main`
- [ ] Select folder: `/ (root)` or `/docs`
- [ ] Wait for deployment (check Actions tab)
- [ ] Verify token list URL is accessible
- [ ] Test JSON validation
- [ ] Add URL to MetaMask token lists
- [ ] Verify tokens appear in MetaMask

---

## 🔗 Related Documentation

- [Token List Hosting Guide](./METAMASK_TOKEN_LIST_HOSTING.md)
- [Quick Start Guide](./METAMASK_QUICK_START_GUIDE.md)

---

**Last Updated**: $(date)

