# Chain 138 Snap — Troubleshooting (balance, swap, data)

If **installation fails** (“snap is not on the allowlist”), **main balance or USD value is not showing**, **swap is malfunctioning**, or **historical/data not loading** when using the Chain 138 Snap with MetaMask (including Flask), use this guide.

---

## 1. Installation fails: "The snap is not on the allowlist"

**What you see:** When adding the Snap in MetaMask you get:

- **"Connection failed — Fetching of chain138-snap failed, check your network and try again."**
- **"Cannot install version '0.1.2' of snap 'npm:chain138-snap': The snap is not on the allowlist."**

**Cause:** MetaMask only allows installing Snaps that use **protected permissions** (such as `endowment:rpc` and `endowment:network-access`) if the Snap is on their **allowlist**. The Chain 138 Snap uses those permissions, so it must be allowlisted. The Snap is published on npm and has been **submitted** for allowlisting; until MetaMask/Consensys approves it, standard MetaMask will block installation.

**What you can do:**

1. **Use MetaMask Flask (workaround now)**  
   [MetaMask Flask](https://metamask.io/flask/) is the development build and **does not enforce the allowlist**. Install Flask, then add the Snap using the same ID: `npm:chain138-snap`. The Snap works the same once installed.

2. **Wait for allowlist approval**  
   Once the Snap is approved, it will be installable in standard MetaMask. No code changes are required on your side.

3. **Operators:** If you submitted the allowlist form and it has been pending for a long time, you can follow up via the [MetaMask Snaps allowlist process](https://docs.metamask.io/snaps/how-to/get-allowlisted/#1-submit-your-snap). For new versions (e.g. 0.1.3), use the [Snaps Directory Information Update form](https://docs.metamask.io/snaps/how-to/get-allowlisted/#5-update-your-snap) to add the new version. Pre-filled fields for the submission are in [ALLOWLIST_FORM_FIELDS.md](../ALLOWLIST_FORM_FIELDS.md).

---

## 2. Main balance / USD not showing ($0.00, "No conversion rate available")

**What you see:** MetaMask shows **$0.00** or **"No conversion rate available"** for ETH (or other tokens) even when you hold a non‑zero balance (e.g. 1,000 ETH).

**Cause:** The **main wallet balance and USD value** are provided by **MetaMask (Consensys)**, not by the Snap. MetaMask gets conversion rates from its own providers (e.g. LavaPack). **Chain 138 (DeFi Oracle Meta Mainnet) is not in that list**, so MetaMask has no price feed for it and shows no USD value.

**This is expected** for custom chains until Consensys or price providers add support.

**What you can do:**

- **Trust the token quantity:** Your on‑chain balance (e.g. "1,000 ETH") is correct; only the USD conversion is missing in the wallet UI.
- **Use the Snap for prices:** Open the **Snap companion site** (e.g. https://explorer.d-bis.org/snap/) and use **"Show market data"** or **"Fetch market summary"**. Those use the token‑aggregation API (see §5) and can show USD prices for Chain 138 tokens.
- **Long‑term:** Submit Chain 138 and tokens to CoinGecko/CMC and/or Consensys so native MetaMask USD may be supported later (see project docs, e.g. `COINGECKO_SUBMISSION_GUIDE`, Consensys outreach).

---

## 3. "We could not fetch any historical data"

**What you see:** In the token/asset detail view, MetaMask shows a raccoon mascot and **"We could not fetch any historical data"** with time range buttons (1D, 1W, 1M, etc.).

**Cause:** Historical price/chart data is also supplied by **MetaMask’s portfolio/price providers**, which do not support Chain 138.

**What you can do:** This is a MetaMask UI limitation. Use the Snap’s market data (companion site) or external explorers/APIs for historical data on Chain 138.

---

## 4. Swap malfunctioning (in‑wallet Swap button)

**What you see:** Clicking **Swap** in MetaMask on Chain 138 fails or shows errors (e.g. "No XChain Swaps native asset found for chainId: eip155:138").

**Cause:** MetaMask’s **in‑wallet Swap** feature does **not** support Chain 138. It only supports chains in their native Swaps list.

**What you can do:**

- **Send ETH on Chain 138:** Use the dedicated **Send on Chain 138** page:  
  https://explorer.d-bis.org/snap/send  
  It uses `eth_sendTransaction` from the dApp context and works on Chain 138 (see `packages/site/src/pages/send.tsx`).
- **Swap quotes via Snap:** On the Snap companion site, use the **Swap quote** card: enter token In/Out and amount, then **"Get quote"** or **"Show quote in Snap"**. This uses the token‑aggregation API. Executing the actual swap must be done in your dApp or a DEX that supports Chain 138, not via MetaMask’s Swap button.
- **WETH display quirk:** If you see wrong WETH balance formatting (e.g. "6,000,000,000.0T WETH"), see [METAMASK_WETH9_DISPLAY_BUG.md](../../docs/METAMASK_WETH9_DISPLAY_BUG.md) (token list / decimals).

---

## 5. Snap market data / swap quote / bridge not loading

**What you see:** On the companion site (e.g. https://explorer.d-bis.org/snap/), **"Show market data"**, **"Fetch market summary"**, **"Get quote"** / **"Show quote in Snap"**, or **bridge routes** show an error or "Set GATSBY_SNAP_API_BASE_URL".

**Cause:** Those features need a **token‑aggregation–compatible API**. The Snap calls:

- `GET {apiBaseUrl}/api/v1/networks`
- `GET {apiBaseUrl}/api/v1/tokens?chainId=138&limit=...`
- `GET {apiBaseUrl}/api/v1/quote?chainId=138&tokenIn=...&tokenOut=...&amountIn=...`
- `GET {apiBaseUrl}/api/v1/bridge/routes`
- etc.

The companion site passes `apiBaseUrl` from **GATSBY_SNAP_API_BASE_URL** at **build time**. If that URL does not serve the token‑aggregation API (see `smom-dbis-138/services/token-aggregation` and [REST_API_REFERENCE.md](../../../smom-dbis-138/services/token-aggregation/docs/REST_API_REFERENCE.md)), those calls fail.

**What you can do:**

1. **If you build with `GATSBY_SNAP_API_BASE_URL=https://explorer.d-bis.org`**  
   Then **explorer.d-bis.org** must expose the token‑aggregation API. The explorer’s normal Blockscout/Go APIs do **not** implement `/api/v1/networks`, `/api/v1/tokens`, `/api/v1/quote`, etc. You must either:
   - **Deploy the token‑aggregation service** (from `smom-dbis-138/services/token-aggregation`) and **proxy** its routes under `https://explorer.d-bis.org/api/v1/...`. On the explorer VM (VMID 5000), run **`explorer-monorepo/scripts/apply-nginx-token-aggregation-proxy.sh`** (default upstream **3001**; set `TOKEN_AGG_PORT=3000` for local-style installs) or ensure the nginx config includes a `location /api/v1/` proxy before the broader `location /api/`. The script **`fix-nginx-conflicts-vmid5000.sh`** in the same repo applies the full template (HTTP + HTTPS) when used.
   - Or use a **separate API host** (see below).

2. **If the token‑aggregation service runs elsewhere** (e.g. `https://api.d-bis.org` or an internal URL):  
   Build the Snap site with that base URL:

   ```bash
   export GATSBY_SNAP_API_BASE_URL=https://your-token-aggregation-host
   bash scripts/build-snap-site-for-explorer.sh
   ```

   Deploy the built `packages/site/public/` to `/var/www/html/snap/` (or your Snap host). Then the companion site will pass the correct `apiBaseUrl` to the Snap and market/swap/bridge can work.

3. **Local development:** Set `GATSBY_SNAP_API_BASE_URL` in `packages/site/.env` to your token‑aggregation base URL (e.g. `http://localhost:3001` if the service runs there). See [FAQ.md](FAQ.md) (“The companion site shows ‘Set GATSBY_SNAP_API_BASE_URL’”).

---

## 6. No icons or tokens showing in MetaMask Flask

**What you see:** MetaMask Flask shows no token icons, no chain icons, or no tokens from the token list when viewing Chain 138 or ALL Mainnet.

**Cause:** MetaMask does not auto-load tokens from the Snap. Chain 138 is not in MetaMask’s built-in token detection (which only covers Ethereum, Polygon, Arbitrum, etc.). You must add the token list URL manually. Icons come from `logoURI` (per token) and `iconUrls` (per network) in the API responses; if those URLs are missing or unreachable, MetaMask shows no icons.

**What you can do:**

1. **Get and add the token list URL**
   - Open the Snap companion site (e.g. https://explorer.d-bis.org/snap/).
   - Connect MetaMask Flask and install the Snap.
   - Click **"Show dynamic info"** (requires `GATSBY_SNAP_API_BASE_URL` to be set at build time).
   - The Snap dialog shows the **Token list URL** (e.g. `https://explorer.d-bis.org/api/v1/report/token-list`).
   - Add that URL in MetaMask: **Settings → Security & Privacy → Token list** (or equivalent), if your MetaMask version supports custom token list URLs.

2. **If MetaMask does not support custom token list URLs**
   - Add tokens manually: **Tokens** tab → **Import tokens** → **Custom token** → enter the token contract address for Chain 138 (e.g. cUSDC, cUSDT from the explorer or [CHAIN138_TOKEN_ADDRESSES](../../../docs/11-references/CHAIN138_TOKEN_ADDRESSES.md)).

3. **Ensure `apiBaseUrl` is set and reachable**
   - The companion site must be built with `GATSBY_SNAP_API_BASE_URL` pointing at the token-aggregation API.
   - Verify: `curl "https://explorer.d-bis.org/api/v1/report/token-list?chainId=138"` returns valid JSON with `tokens` and each token has `logoURI`.

4. **Icons not showing**
   - Token icons: Each token in the token list must have a valid `logoURI`. The token-aggregation API provides these from `canonical-tokens.ts` (Trust Wallet assets).
   - Network icons: `GET /api/v1/networks` must return `iconUrls` for each chain. Each network has a primary URL (e.g. `explorer.d-bis.org/favicon.ico`) and a fallback (Trust Wallet ETH logo). If the primary 404s, MetaMask uses the fallback. Operators: add `favicon.ico` to explorer and alltra sites if missing.
   - If logo URLs (e.g. raw.githubusercontent.com) are blocked or return 404, operators can host logos locally and update `canonical-tokens.ts` or `networks.ts`.

**Operators:** See [PRE_PUBLISH_TESTING.md](../PRE_PUBLISH_TESTING.md) §4.3 (token list logoURI) and §4.4 (network iconUrls) for verification steps.

---

## 7. Permissions and connected site

The Snap needs:

- **Access the internet** — to call the token‑aggregation API.
- **Display dialog windows in MetaMask** — for market data, swap quote, bridge dialogs.
- **Allow websites to communicate directly with Chain 138** — so the companion site (e.g. explorer.d-bis.org) can invoke the Snap.

If market/swap work on the companion site but not from another origin, ensure that site is **connected** in MetaMask (Snap settings → Connected sites) and that you’re using the same Snap origin (e.g. `npm:chain138-snap`) and correct `apiBaseUrl`.

---

## 8. Quick reference

| Issue                                         | Cause                                                     | Action                                                                                                                                 |
| --------------------------------------------- | --------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| Installation: "snap is not on the allowlist" | Snap not yet approved on MetaMask allowlist               | Use [MetaMask Flask](https://metamask.io/flask/) to install now; or wait for allowlist approval                                        |
| No icons or tokens in MetaMask Flask          | Token list not added; Chain 138 not in built-in detection | Use "Show dynamic info" to get token list URL; add in MetaMask Settings → Token list; or add tokens manually                           |
| Main balance USD = $0.00 / no conversion rate | MetaMask has no price feed for Chain 138                  | Use Snap “Show market data” or accept quantity-only in wallet                                                                          |
| Historical data not loading                   | MetaMask portfolio doesn’t support Chain 138              | Use Snap/explorer or external APIs                                                                                                     |
| In‑wallet Swap fails                          | MetaMask Swap doesn’t support Chain 138                   | Use [Send on Chain 138](https://explorer.d-bis.org/snap/send); get swap quotes from Snap companion site and execute swap in dApp/DEX   |
| Snap market/swap/bridge errors                | `apiBaseUrl` not set or not serving token‑aggregation API | Set GATSBY_SNAP_API_BASE_URL to token‑aggregation host; ensure `/api/v1/...` is available there (or proxy it under explorer.d-bis.org) |

---

**Related docs**

- [TOKEN_LIST_AND_ICONS_GUIDE.md](TOKEN_LIST_AND_ICONS_GUIDE.md) — how to add token list URL and fix icons
- [FAQ.md](FAQ.md) — apiBaseUrl, permissions, “Set GATSBY_SNAP_API_BASE_URL”
- [TESTING_INSTRUCTIONS.md](../TESTING_INSTRUCTIONS.md) — testing market summary, swap quote, bridge
- [METAMASK_WETH9_DISPLAY_BUG.md](../../docs/METAMASK_WETH9_DISPLAY_BUG.md) — WETH balance display
- Token‑aggregation API: `smom-dbis-138/services/token-aggregation/docs/REST_API_REFERENCE.md`
