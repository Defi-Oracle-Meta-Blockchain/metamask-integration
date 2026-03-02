# Chain 138 Snap — Token List and Icons Guide

How to display tokens and icons in MetaMask when using the Chain 138 Snap.

---

## Why tokens and icons may not show

- **Chain 138 is not in MetaMask’s built-in token detection.** MetaMask only auto-detects tokens on Ethereum, Polygon, Arbitrum, Optimism, Base, zkSync, etc. Chain 138 and ALL Mainnet (651940) are custom chains, so you must add the token list or import tokens manually.
- **Icons come from the token list.** Each token needs a `logoURI` and each network needs `iconUrls`. If those URLs are missing or unreachable, MetaMask shows no icons.

---

## Step 1: Get the token list URL

1. Open the Snap companion site (e.g. https://explorer.d-bis.org/snap/).
2. Connect MetaMask (or MetaMask Flask) and install the Chain 138 Snap.
3. Click **"Show dynamic info"**.
4. The Snap dialog shows the **Token list URL** (e.g. `https://explorer.d-bis.org/api/v1/report/token-list`).

---

## Step 2: Add the token list in MetaMask

### If MetaMask supports custom token list URLs

- Go to **Settings → Security & Privacy** (or equivalent).
- Find **Token list** and add the URL from Step 1.
- MetaMask will fetch the list and display tokens with icons when you switch to Chain 138 or ALL Mainnet.

### If MetaMask does not support custom token list URLs

Add tokens manually:

1. Switch to Chain 138 in MetaMask.
2. Go to **Tokens** tab → **Import tokens** (or the plus button).
3. Select **Custom token**.
4. Enter the token contract address (see [CHAIN138_TOKEN_ADDRESSES](../../../docs/11-references/CHAIN138_TOKEN_ADDRESSES.md) for cUSDC, cUSDT, etc.).
5. MetaMask will fill symbol and decimals. Click **Import**.

---

## Step 3: Verify icons

If tokens show but icons are missing:

- **Token icons:** The token-aggregation API (`GET /api/v1/report/token-list`) must return a `logoURI` for each token. Operators: see [PRE_PUBLISH_TESTING.md](PRE_PUBLISH_TESTING.md) §4.3.
- **Network icons:** The networks API (`GET /api/v1/networks`) must return `iconUrls` for each chain. Operators: see [PRE_PUBLISH_TESTING.md](PRE_PUBLISH_TESTING.md) §4.4.
- **Logo URLs:** If logo URLs (e.g. raw.githubusercontent.com) are blocked or return 404, operators can host logos locally and update the token-aggregation config.

---

## Operators: verify API and icons

Run the verification script to check token list, networks, logoURIs, and iconUrls:

```bash
./scripts/verify-snap-api-and-icons.sh [API_BASE_URL]
# Example: ./scripts/verify-snap-api-and-icons.sh https://explorer.d-bis.org
```

---

## Related docs

- [CHAIN138_SNAP_TROUBLESHOOTING.md](CHAIN138_SNAP_TROUBLESHOOTING.md) — §6 No icons or tokens showing
- [PRE_PUBLISH_TESTING.md](PRE_PUBLISH_TESTING.md) — §4.3 Token list logoURI, §4.4 Network iconUrls
