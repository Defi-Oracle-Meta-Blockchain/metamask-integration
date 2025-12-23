# MetaMask Token List Hosting Guide

**Date**: $(date)  
**Purpose**: Guide for hosting the MetaMask token list publicly

---

## 📋 Overview

The MetaMask token list (`METAMASK_TOKEN_LIST.json`) needs to be hosted on a public URL for automatic token discovery in MetaMask.

---

## 🚀 Hosting Options

### Option 1: GitHub Pages (Recommended)

**Advantages**:
- Free hosting
- Easy to set up
- Automatic HTTPS
- Version control
- CDN-backed

**Steps**:

1. **Prepare Token List**
   ```bash
   cd /home/intlc/projects/proxmox
   bash scripts/host-token-list.sh github
   ```
   This creates `token-list.json` in the project root.

2. **Create GitHub Repository** (if not exists)
   - Create a new public repository
   - Or use existing repository

3. **Add Token List to Repository**
   ```bash
   git add token-list.json
   git commit -m "Add MetaMask token list for ChainID 138"
   git push
   ```

4. **Enable GitHub Pages**
   - Go to repository Settings → Pages
   - Select branch (usually `main` or `master`)
   - Select folder: `/ (root)`
   - Click Save

5. **Access Token List**
   - URL format: `https://<username>.github.io/<repo>/token-list.json`
   - Example: `https://yourusername.github.io/token-list/token-list.json`

6. **Add to MetaMask**
   - MetaMask → Settings → Security & Privacy → Token Lists
   - Click "Add custom token list"
   - Enter your GitHub Pages URL
   - Click "Add"

---

### Option 2: IPFS (Decentralized)

**Advantages**:
- Decentralized hosting
- Permanent URLs
- No single point of failure
- Censorship-resistant

**Steps**:

1. **Install IPFS** (if not installed)
   ```bash
   # Follow: https://docs.ipfs.io/install/
   ```

2. **Start IPFS Node**
   ```bash
   ipfs daemon
   ```

3. **Add Token List to IPFS**
   ```bash
   cd /home/intlc/projects/proxmox
   ipfs add docs/METAMASK_TOKEN_LIST.json
   ```

4. **Pin the File** (to keep it available)
   ```bash
   ipfs pin add <hash>
   ```

5. **Access Token List**
   - IPFS Gateway: `https://ipfs.io/ipfs/<hash>`
   - Pinata Gateway: `https://gateway.pinata.cloud/ipfs/<hash>`
   - Cloudflare Gateway: `https://cloudflare-ipfs.com/ipfs/<hash>`

6. **Add to MetaMask**
   - Use any of the gateway URLs above
   - Add to MetaMask token lists

**Note**: IPFS hashes are permanent. If you update the token list, you'll get a new hash.

---

### Option 3: Custom Domain/Server

**Advantages**:
- Full control
- Branded URL
- Custom CDN
- Professional appearance

**Steps**:

1. **Copy Token List to Server**
   ```bash
   scp docs/METAMASK_TOKEN_LIST.json user@server:/var/www/html/token-list.json
   ```

2. **Configure Web Server** (nginx example)
   ```nginx
   location /token-list.json {
       add_header Access-Control-Allow-Origin *;
       add_header Access-Control-Allow-Methods "GET, OPTIONS";
       add_header Content-Type application/json;
       try_files $uri =404;
   }
   ```

3. **Ensure HTTPS**
   - Use Let's Encrypt or similar
   - MetaMask requires HTTPS for token lists

4. **Access Token List**
   - URL: `https://your-domain.com/token-list.json`

5. **Add to MetaMask**
   - Use your custom domain URL

---

## ✅ Verification

### Test Token List URL

```bash
# Test accessibility
curl -I https://your-url.com/token-list.json

# Should return:
# HTTP/2 200
# Content-Type: application/json
# Access-Control-Allow-Origin: *
```

### Validate JSON

```bash
# Validate JSON structure
curl https://your-url.com/token-list.json | jq .

# Should return valid JSON without errors
```

### Test in MetaMask

1. Add token list URL to MetaMask
2. Verify tokens appear automatically
3. Check token metadata (name, symbol, decimals)
4. Verify logos load (if configured)

---

## 📝 Token List Updates

### Updating the Token List

1. **Update Local File**
   - Edit `docs/METAMASK_TOKEN_LIST.json`
   - Increment version number
   - Update timestamp

2. **Deploy Update**
   - **GitHub Pages**: Commit and push changes
   - **IPFS**: Add new file, get new hash, update URL
   - **Custom Server**: Upload new file

3. **Version Control**
   - Keep version numbers in sync
   - Document changes in commit messages
   - Consider semantic versioning

---

## 🔧 Current Token List

**File**: `docs/METAMASK_TOKEN_LIST.json`

**Tokens Included**:
1. **ETH/USD Price Feed** (`0x3304b747e565a97ec8ac220b0b6a1f6ffdb837e6`)
   - Decimals: 8
   - Symbol: ETH-USD

2. **WETH9** (`0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2`)
   - Decimals: 18
   - Symbol: WETH

3. **WETH10** (`0xf4BB2e28688e89fCcE3c0580D37d36A7672E8A9f`)
   - Decimals: 18
   - Symbol: WETH10

---

## 🎯 Recommended Approach

**For Production**: Use **GitHub Pages**
- Easy to maintain
- Free hosting
- Automatic HTTPS
- Version control built-in

**For Decentralization**: Use **IPFS**
- Permanent URLs
- Decentralized
- Censorship-resistant

**For Branding**: Use **Custom Domain**
- Professional appearance
- Full control
- Custom CDN options

---

## 📚 Related Documentation

- [MetaMask Integration Complete](./METAMASK_INTEGRATION_COMPLETE.md)
- [Token List File](./METAMASK_TOKEN_LIST.json)
- [Hosting Script](../scripts/host-token-list.sh)

---

**Last Updated**: $(date)

