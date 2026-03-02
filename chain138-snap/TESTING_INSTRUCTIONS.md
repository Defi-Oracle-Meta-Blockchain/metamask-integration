# Chain 138 Snap Testing Instructions

**Date:** 2026-01-30  
**Status:** Built and ready for testing

**Thorough pre-publish testing:** For a complete pass before every npm publish (including **all logos/images**, every RPC method, companion site, Send page, production-like test, and recommendations), use **[docs/PRE_PUBLISH_TESTING.md](docs/PRE_PUBLISH_TESTING.md)**.

---

## Prerequisites

1. **MetaMask Flask** (development version of MetaMask)
   - Download: https://metamask.io/flask/
   - Install as separate browser extension (won't conflict with regular MetaMask)

2. **Snap Development Server Running**

   ```bash
   pnpm run start
   ```

   (From the repo root.)
   (Or use **yarn start** if you prefer Yarn; see [PACKAGE_MANAGER.md](PACKAGE_MANAGER.md).)
   - Server will start on http://localhost:8000
   - Keep this terminal open

3. **For full E2E (API-dependent features):** Token-aggregation service and companion site env. See [E2E Preparation](E2E_PREPARATION.md).

---

## E2E Preparation

For full end-to-end success (market data, bridge routes, swap quotes), complete these before running the checklist:

1. **Start token-aggregation** (local or use a deployed URL).
   - See [E2E_PREPARATION.md](E2E_PREPARATION.md) for steps (database, env, `npm run dev` or Docker).
   - Note the API base URL (e.g. `http://localhost:3000` for local).

2. **Configure companion site env.**
   - In `packages/site`, copy `.env.production.dist` to `.env` or `.env.production`.
   - Set `GATSBY_SNAP_API_BASE_URL` to the token-aggregation base URL (e.g. `http://localhost:3000`).
   - Restart the site if it is already running so the variable is picked up.

3. **Run Snap + site:** From repo root, `pnpm run start` (serves site and Snap on http://localhost:8000).

4. **Install MetaMask Flask** and use the checklist in [E2E testing checklist (MetaMask Flask)](#e2e-testing-checklist-metamask-flask) below.

**Automated E2E (optional):** Run `pnpm run test:e2e` to start the dev server (if needed) and run Playwright tests against the companion site. See [E2E_PREPARATION.md](E2E_PREPARATION.md#5-optional-automated-e2e-playwright). This does not drive MetaMask Flask.

---

## Testing Steps

### 1. Install the Snap

1. Open browser with MetaMask Flask installed
2. Navigate to **http://localhost:8000**
3. You should see the Snap installation page
4. Click **"Connect"** to install the Snap
5. MetaMask Flask will prompt for permissions - approve them

### 2. Test RPC Methods

Once installed, you can test the Snap's RPC methods:

#### Test `get_networks`

Pass `apiBaseUrl` (your token-aggregation service URL). Open browser console:

```javascript
await ethereum.request({
  method: 'wallet_invokeSnap',
  params: {
    snapId: 'local:http://localhost:8000',
    request: {
      method: 'get_networks',
      params: { apiBaseUrl: 'https://your-token-aggregation-api.com' },
    },
  },
});
```

**Expected response:** `{ version, networks: [ ... ] }` with full EIP-3085 params for Chain 138, Ethereum Mainnet, and ALL Mainnet.

**Optional:** You can pass `networksUrl` instead of (or without) `apiBaseUrl` to fetch networks from a JSON URL (e.g. GitHub raw):

```javascript
params: {
  networksUrl: 'https://raw.githubusercontent.com/org/repo/main/networks.json';
}
```

#### Test `get_chain138_config`

Requires `apiBaseUrl`. Returns Chain 138 config from the API:

```javascript
await ethereum.request({
  method: 'wallet_invokeSnap',
  params: {
    snapId: 'local:http://localhost:8000',
    request: {
      method: 'get_chain138_config',
      params: { apiBaseUrl: 'https://your-token-aggregation-api.com' },
    },
  },
});
```

**Expected response:** Chain 138 params (chainId, chainName, rpcUrls, nativeCurrency, blockExplorerUrls, oracles).

**Optional:** Pass `networksUrl` instead of `apiBaseUrl` to use a remote networks JSON.

#### Test `get_chain138_market_chains`

```javascript
await ethereum.request({
  method: 'wallet_invokeSnap',
  params: {
    snapId: 'local:http://localhost:8000',
    request: {
      method: 'get_chain138_market_chains',
      params: {
        apiBaseUrl: 'https://your-token-aggregation-api.com', // When deployed
      },
    },
  },
});
```

**Expected response:**

```json
[
  {
    "chainId": 138,
    "name": "DeFi Oracle Meta Mainnet",
    "nativeToken": { "symbol": "ETH", "decimals": 18 },
    "rpcUrl": "https://rpc-http-pub.d-bis.org",
    "explorerUrl": "https://explorer.d-bis.org"
  }
]
```

#### Test `get_market_summary`

Requires `apiBaseUrl` (token-aggregation service URL). Fetches tokens with optional market data (price, volume) for a chain. Optional `chainId` (default 138).

```javascript
await ethereum.request({
  method: 'wallet_invokeSnap',
  params: {
    snapId: 'local:http://localhost:8000',
    request: {
      method: 'get_market_summary',
      params: {
        apiBaseUrl: 'https://your-token-aggregation-api.com',
        chainId: 138, // optional, default 138
      },
    },
  },
});
```

**Expected response:** `{ tokens: [ { symbol, name, address, market?: { priceUsd, volume24h } } ] }` or `{ error, tokens: [] }` on failure.

#### Test `show_market_data`

Requires `apiBaseUrl`. Opens a Snap dialog listing token symbols and USD prices from the token-aggregation API.

```javascript
await ethereum.request({
  method: 'wallet_invokeSnap',
  params: {
    snapId: 'local:http://localhost:8000',
    request: {
      method: 'show_market_data',
      params: {
        apiBaseUrl: 'https://your-token-aggregation-api.com',
        chainId: 138, // optional
      },
    },
  },
});
```

**Expected:** A MetaMask dialog showing "Market data (Chain 138)" and token lines with prices. Without `apiBaseUrl`, the Snap shows an alert asking to pass it.

#### Test `get_token_list` and `get_token_list_url`

With `apiBaseUrl`: same pattern as above; the Snap calls `${apiBaseUrl}/api/v1/report/token-list` (optional `chainId` in params).  
**Optional:** Pass `tokenListUrl` to fetch the token list from a JSON URL (e.g. GitHub raw):

```javascript
params: { tokenListUrl: 'https://raw.githubusercontent.com/org/repo/main/token-list.json', chainId: 138 }
```

#### Test `get_bridge_routes`

Requires `apiBaseUrl` or `bridgeListUrl`. Returns bridge routes: CCIP (WETH9/WETH10) and, when configured, Trustless (Lockbox on 138) and Chain 138 bridge addresses.

```javascript
await ethereum.request({
  method: 'wallet_invokeSnap',
  params: {
    snapId: 'local:http://localhost:8000',
    request: {
      method: 'get_bridge_routes',
      params: { apiBaseUrl: 'https://your-token-aggregation-api.com' },
    },
  },
});
```

**Expected response:** `{ routes: { weth9: {...}, weth10: {...} }, chain138Bridges: { weth9, weth10 } }`.

**Optional:** Pass `bridgeListUrl` instead of `apiBaseUrl` to fetch bridge list from a JSON URL.

#### Test `show_bridge_routes`

Requires `apiBaseUrl` or `bridgeListUrl`. Opens a Snap dialog with bridge route summary: CCIP (WETH9/WETH10) and Trustless (Lockbox) → Ethereum Mainnet.

```javascript
await ethereum.request({
  method: 'wallet_invokeSnap',
  params: {
    snapId: 'local:http://localhost:8000',
    request: {
      method: 'show_bridge_routes',
      params: { apiBaseUrl: 'https://your-token-aggregation-api.com' },
    },
  },
});
```

#### Test `get_swap_quote`

Requires `apiBaseUrl`, `tokenIn`, `tokenOut`, `amountIn` (raw amount string). Optional `chainId` (default 138).

```javascript
await ethereum.request({
  method: 'wallet_invokeSnap',
  params: {
    snapId: 'local:http://localhost:8000',
    request: {
      method: 'get_swap_quote',
      params: {
        apiBaseUrl: 'https://your-token-aggregation-api.com',
        chainId: 138,
        tokenIn: '0x...',
        tokenOut: '0x...',
        amountIn: '1000000000000000000',
      },
    },
  },
});
```

**Expected response:** `{ amountOut: string | undefined, error?: string, poolAddress?: string }`.

#### Test `show_swap_quote`

Same params as `get_swap_quote`. Opens a Snap dialog with the quote (In/Out raw amounts).

#### Test `hello` (basic test)

```javascript
await ethereum.request({
  method: 'wallet_invokeSnap',
  params: {
    snapId: 'local:http://localhost:8000',
    request: {
      method: 'hello',
    },
  },
});
```

**Expected response:**

```json
"Hello from Chain 138 Snap!"
```

---

## E2E testing checklist (MetaMask Flask)

Use this checklist for full manual E2E testing:

1. **Environment**
   - [ ] MetaMask Flask installed
   - [ ] Snap dev server running: `pnpm run start` (or `yarn start`) in the repo root
   - [ ] For API-dependent tests: token-aggregation service reachable. Set `apiBaseUrl` to your deployment (e.g. `https://your-token-aggregation-api.com`) or a local/staging URL (e.g. `http://localhost:3000` if running token-aggregation locally).

2. **Install Snap**
   - [ ] Open http://localhost:8000 in the browser
   - [ ] Click **Connect** and approve Snap installation in MetaMask Flask

3. **RPC methods (apiBaseUrl or optional networksUrl / tokenListUrl / bridgeListUrl)**
   - [ ] `hello`
   - [ ] `get_networks` (apiBaseUrl or networksUrl)
   - [ ] `get_chain138_config` (apiBaseUrl or networksUrl)
   - [ ] `get_chain138_market_chains` (apiBaseUrl)
   - [ ] `get_token_list`, `get_token_list_url` (apiBaseUrl or tokenListUrl; optional chainId)
   - [ ] `get_oracles` (apiBaseUrl), `show_dynamic_info` (apiBaseUrl or networksUrl/tokenListUrl)
   - [ ] `get_market_summary`, `show_market_data` (apiBaseUrl; optional chainId)
   - [ ] `get_bridge_routes`, `show_bridge_routes` (apiBaseUrl or bridgeListUrl)
   - [ ] `get_swap_quote`, `show_swap_quote` (apiBaseUrl, tokenIn, tokenOut, amountIn; optional chainId)

4. **Companion site cards**
   - [ ] Set `GATSBY_SNAP_API_BASE_URL` in `.env` (copy from `.env.production.dist` and fill) so the site passes apiBaseUrl to the Snap.
   - [ ] **Market data:** "Show market data" opens Snap dialog; "Fetch market summary" displays tokens/prices below.
   - [ ] **Bridge:** "Show bridge routes" opens Snap dialog with CCIP and Trustless routes.
   - [ ] **Swap quote:** Enter token In/Out addresses and amount (raw), then "Get quote" shows amountOut; "Show quote in Snap" opens dialog.

---

## Troubleshooting

### Snap not appearing in MetaMask Flask

- Ensure dev server is running on port 8000
- Check browser console for errors
- Try refreshing the page

### Permission errors

- Snap needs `endowment:network-access` for API calls
- Check `snap.manifest.json` has correct permissions

### API calls failing

- Ensure `apiBaseUrl` is provided for methods that need it, or use the optional URL params: `networksUrl`, `tokenListUrl`, `bridgeListUrl` (see RPC method sections above).
- On the companion site, set `GATSBY_SNAP_API_BASE_URL` in `.env` or `.env.production` (see `packages/site/.env.production.dist`) so Market data and other API-dependent cards work.
- Check CORS settings on the token-aggregation API server (it uses `cors()` by default).
- Verify API endpoint is accessible (e.g. token-aggregation and, for full testing, bridge/quote endpoints).

---

## Next Steps

### After Testing

1. **Fix any bugs** found during testing
2. **Submit to Snap directory** when ready (see Publishing below)

### Publishing

**Checklist before publishing:**

- [ ] **Thorough test:** Complete [docs/PRE_PUBLISH_TESTING.md](docs/PRE_PUBLISH_TESTING.md) (build, logos/images, all RPC methods, companion site, Send page, production-like, final sign-off).
- [ ] All manual E2E checklist items above completed and passing.
- [ ] Token-aggregation (or your API) deployed and stable; production `apiBaseUrl` known.
- [ ] Snap built with no errors; `prepublishOnly` has run (updates manifest shasum).
- [ ] `packages/snap/package.json`: `name` and `publishConfig` (e.g. `"access": "public"`) correct for npm.
- [ ] Integrator docs updated: dApps/site must pass `apiBaseUrl` (or optional `networksUrl` / `tokenListUrl` / `bridgeListUrl`) for market data, bridge, and swap quote.

**Snap directory submission checklist:**

- [ ] All manual E2E checklist items in this doc completed and passing.
- [ ] Snap built with `pnpm run build`; `prepublishOnly` has run (manifest shasum updated).
- [ ] `packages/snap/package.json`: `name`, `version`, `publishConfig` (e.g. `"access": "public"`) correct for npm.
- [ ] `snap.manifest.json`: `description`, `proposedName`, `initialPermissions` match what the Snap uses; `source.location.npm` will be valid after publish.
- [ ] Snap package published to npm so the manifest npm source is resolvable.
- [ ] [MetaMask Snap publishing guide](https://docs.metamask.io/snaps/how-to/publish-a-snap/) followed: register Snap (package name or bundle URL), description, category, permissions.
- [ ] Integrator docs: dApps/site must pass `apiBaseUrl` (or optional `networksUrl` / `tokenListUrl` / `bridgeListUrl`) for market data, bridge, swap quote.

**Steps to publish to MetaMask Snap directory:**

1. **Build:** Run `pnpm run build` (or **yarn build**; see [PACKAGE_MANAGER.md](PACKAGE_MANAGER.md)). The `prepublishOnly` script updates the manifest shasum.
2. **Publish package:** Publish the Snap package to npm (e.g. from `packages/snap`) so `source.location.npm` in `snap.manifest.json` is valid.
3. **Snap directory:** Follow the [MetaMask Snap publishing guide](https://docs.metamask.io/snaps/how-to/publish-a-snap/) to register the Snap (package name or bundle URL, description, category, permissions).

**Production use:** After the Snap is published, the production Snap ID is **`npm:chain138-snap`**. For market data, swap quote, and bridge routes to work, dApps (and the companion site) must pass `apiBaseUrl` (your token-aggregation service URL) or the optional URLs (`networksUrl`, `tokenListUrl`, `bridgeListUrl`) when invoking the Snap. See "Integrators" in the repo README and "API calls failing" in Troubleshooting.

---

## Snap Capabilities

### Current Features

- ✅ Get Chain 138 configuration (`get_chain138_config`, `get_networks`)
- ✅ Token list and token list URL (`get_token_list`, `get_token_list_url`)
- ✅ Market data: `get_market_summary` (tokens with prices), `show_market_data` (dialog)
- ✅ Oracles config (`get_oracles`), dynamic info dialog (`show_dynamic_info`)
- ✅ Bridge routes (`get_bridge_routes`, `show_bridge_routes`) — CCIP and Trustless — when bridge API is available
- ✅ Swap quote (`get_swap_quote`, `show_swap_quote`) when quote API is available

---

**Last updated:** 2026-02-11  
**Status:** Ready for manual testing in MetaMask Flask; Playwright E2E available via `pnpm run test:e2e`
