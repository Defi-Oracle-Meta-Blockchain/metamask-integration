# Thorough Pre-Publish Testing Guide — Chain 138 Snap

Use this guide to **thoroughly test the Snap before every npm publish** and before submitting or updating the Snap in the MetaMask directory. It covers build, assets (logos/images), every RPC method, companion site, Send page, production-like flows, and recommendations. No details (including chain/token logos) are left out.

---

## 1. Overview and when to use

- **Purpose:** Ensure the Snap and companion site work end-to-end, all assets (icons, logos) are present and reachable, and the package is ready for npm and (optionally) the MetaMask directory.
- **When:** Before each `pnpm run publish:snap` and before submitting or updating the Snap via the [MetaMask Snaps Directory Information form](https://docs.metamask.io/snaps/how-to/get-allowlisted/#5-update-your-snap).
- **Scope:** Build, unit tests, Snap package contents, **all logos and images**, every RPC method, companion site cards, Send page, production-like test, allowlist checklist, and recommendations.

---

## 2. Prerequisites

### 2.1 MetaMask Flask (for full manual E2E)

- Install: https://metamask.io/flask/
- Use a **separate** browser profile or the Flask build as a separate extension so it does not conflict with regular MetaMask.
- Ensure Flask is unlocked and (optionally) create or import a test wallet you can use on Chain 138.

### 2.2 Token-aggregation API (for market data, swap quote, bridge, token list)

- **Local:** See [E2E_PREPARATION.md](../E2E_PREPARATION.md). Run from `smom-dbis-138/services/token-aggregation` (Node 20+, PostgreSQL if required). Default port **3000**. Verify: `curl http://localhost:3000/api/v1/networks` and `curl http://localhost:3000/api/v1/report/token-list?chainId=138`.
- **Staging/production:** Use a deployed base URL. Ensure CORS allows the Snap/site origin and all required endpoints respond (see E2E_PREPARATION.md §1). Run **`scripts/verify-snap-api-and-icons.sh [API_BASE_URL]`** to verify token list, networks, logoURIs, and iconUrls.

### 2.3 Companion site environment

- In `packages/site`: copy `.env.production.dist` to `.env` (dev) or `.env.production` (production build).
- Set **`GATSBY_SNAP_API_BASE_URL`** to the token-aggregation base URL (e.g. `http://localhost:3000` or `https://explorer.d-bis.org`). No trailing slash.
- For **production-like** test: set **`GATSBY_SNAP_ORIGIN=npm:chain138-snap`** so the site uses the published Snap (after it is on npm).
- Restart the dev server after changing env so Gatsby picks up the variables.

### 2.4 Optional but recommended

- A **real wallet** with a small balance on **Chain 138** (e.g. testnet ETH) to verify Send page and in-wallet display.
- **Deployed companion site** (e.g. https://explorer.d-bis.org/snap/) so you can test from a production URL and from a different origin (MetaMask “Connected sites”).

---

## 3. Build and unit tests

| Step                     | Command                                                 | What to verify                                                                                                             |
| ------------------------ | ------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| Install deps             | `pnpm install`                                          | No peer/version errors.                                                                                                    |
| Build                    | `pnpm run build`                                        | Both `packages/snap` and `packages/site` build successfully. Snap manifest shasum is updated (mm-snap may report “fixed”). |
| Unit tests               | `pnpm run test`                                         | All Jest tests pass (Snap package).                                                                                        |
| Automated E2E (optional) | `npx playwright install` once, then `pnpm run test:e2e` | Playwright tests pass (site loads, Connect/Reconnect/Install visible). Does not drive MetaMask.                            |
| Lint                     | `pnpm run lint`                                         | No ESLint/Prettier errors.                                                                                                 |

**Snap package contents (must be present for publish):**

- [ ] `packages/snap/dist/bundle.js` — exists and non-empty.
- [ ] `packages/snap/images/icon.svg` — exists (referenced in `snap.manifest.json` as `iconPath`).
- [ ] `packages/snap/snap.manifest.json` — `version` matches `packages/snap/package.json`, `source.location.npm.packageName` is `chain138-snap`, `iconPath` is `images/icon.svg`.
- [ ] `packages/snap/package.json` — `files` includes `dist/`, `images/`, `snap.manifest.json`; `publishConfig.access` is `public` if publishing as public.

---

## 4. Logos and images — complete checklist

Nothing should be missing or broken. Verify each of the following.

### 4.1 Snap icon (MetaMask Snap list and detail)

| Item        | Location                        | Check                                                                                                         |
| ----------- | ------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| Snap icon   | `packages/snap/images/icon.svg` | File exists; referenced in `snap.manifest.json` → `source.location.npm.iconPath`.                             |
| In MetaMask | After installing the Snap       | In Settings → Snaps, “Chain 138” shows the purple “138” icon (or your icon). Icon is clear and not pixelated. |

If you use a different format (e.g. PNG), ensure `iconPath` and `files` in package.json include it and the manifest points to the correct path.

### 4.2 Companion site assets

| Item                | Location                                                         | Check                                                    |
| ------------------- | ---------------------------------------------------------------- | -------------------------------------------------------- |
| Site favicon / icon | `packages/site/gatsby-config.ts` → `icon: 'src/assets/logo.svg'` | File exists; build succeeds; browser tab shows the icon. |
| Header logo         | `packages/site/src/components/Header.tsx` → `<SnapLogo />`       | Logo renders in the header; no broken image.             |

Ensure `src/assets/logo.svg` (or the path you use) exists. Add a favicon or apple-touch icon in Gatsby config if required for directory/submission.

### 4.3 Token list — logoURI (token-aggregation API)

The Snap and MetaMask token list depend on **`GET /api/v1/report/token-list`** returning Uniswap-style tokens with **`logoURI`** per token and a **list-level `logoURI`**.

| Check                   | How to verify                                                                                                                                 |
| ----------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| List-level logoURI      | `curl -s "${API_BASE}/api/v1/report/token-list?chainId=138" \| jq '.logoURI'` — present and URL is reachable (e.g. ETH or list logo).         |
| Every token has logoURI | `curl -s "${API_BASE}/api/v1/report/token-list?chainId=138" \| jq '.tokens[] \| {symbol, logoURI}'` — no token has null or missing `logoURI`. |
| URLs resolve            | For each distinct `logoURI` in the response, open in browser or `curl -sI <url>` — expect 200 (or 301/302 to a valid asset).                  |

**Token-aggregation source:** In `smom-dbis-138/services/token-aggregation`, `src/config/canonical-tokens.ts` defines `LOGO_BY_SYMBOL` and `getLogoUriForSpec()`. Defaults use Trust Wallet assets and ethereum.org ETH diamond. For Chain 138–specific tokens, set `logoUrl` on the spec or ensure they fall back to a sensible default (e.g. ETH_LOGO). Add any new token symbols to `LOGO_BY_SYMBOL` or give them a `logoUrl` so no token is missing a logo.

### 4.4 Network icons (iconUrls) — token-aggregation API

**`GET /api/v1/networks`** must return each network with **`iconUrls`** (array of URLs) so wallets can show chain icons.

| Chain                  | Expected iconUrls (examples)                                                        | Verify                                             |
| ---------------------- | ----------------------------------------------------------------------------------- | -------------------------------------------------- |
| Chain 138 (0x8a)       | `https://explorer.d-bis.org/favicon.ico`, ETH diamond or similar                    | Each URL returns 200 (or redirect to valid image). |
| Ethereum Mainnet (0x1) | `https://raw.githubusercontent.com/ethereum/ethereum.org/.../eth-diamond-black.png` | URL reachable.                                     |
| ALL Mainnet (651940)   | `https://alltra.global/favicon.ico`, ETH diamond or similar                         | URL reachable.                                     |

**Token-aggregation source:** `smom-dbis-138/services/token-aggregation/src/config/networks.ts` — each entry in `NETWORKS` has `iconUrls`. Ensure:

- [ ] `explorer.d-bis.org/favicon.ico` exists (explorer site serves a favicon).
- [ ] `alltra.global/favicon.ico` exists (or update to a valid URL).
- [ ] Any raw GitHub or CDN URLs (ethereum.org, Trust Wallet assets) are still valid and not 404.

### 4.5 Suggested screenshot list (for allowlist and docs)

Capture and keep for submission and `docs/images/`:

| File                       | Content                                                           |
| -------------------------- | ----------------------------------------------------------------- |
| `connect.png`              | Companion site with Connect / Install Flask / Reconnect visible.  |
| `market-data-dialog.png`   | Snap dialog from “Show market data” (tokens + prices).            |
| `bridge-routes-dialog.png` | Snap dialog from “Show bridge routes” (CCIP + Trustless).         |
| `swap-quote-dialog.png`    | Snap dialog from “Show quote in Snap”.                            |
| `dynamic-info-dialog.png`  | Snap dialog from `show_dynamic_info` (networks + token list URL). |
| `send-page.png`            | Send on Chain 138 page (network switch + send form).              |

See [FEATURES.md](FEATURES.md) “Screenshots and visuals” and [ALLOWLIST_FORM_FIELDS.md](../ALLOWLIST_FORM_FIELDS.md) “Images”.

---

## 5. RPC methods — full verification table

Test each method (e.g. via browser console `wallet_invokeSnap` from the companion site origin). Use **local** Snap ID for dev (`local:http://localhost:8000` or the URL your dev server uses) or **npm** for production-like (`npm:chain138-snap`).

| Method                       | Params (required / optional)                                        | Expected                                                                      | Verify                                                                                                                 |
| ---------------------------- | ------------------------------------------------------------------- | ----------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| `hello`                      | —                                                                   | `{ message: "Hello, …" }`                                                     | No error; message contains “Chain 138” or similar.                                                                     |
| `get_networks`               | `apiBaseUrl` or `networksUrl`                                       | `{ version, networks: [ … ] }` with EIP-3085 entries for 138, 1, 651940       | Each network has `chainId`, `rpcUrls`, `nativeCurrency`, `blockExplorerUrls`; **iconUrls** present and URLs reachable. |
| `get_chain138_config`        | `apiBaseUrl` or `networksUrl`                                       | Single Chain 138 config object                                                | Matches your chain (e.g. DeFi Oracle Meta Mainnet, RPCs, explorer).                                                    |
| `get_chain138_market_chains` | `apiBaseUrl`                                                        | `{ chains: [ … ] }`                                                           | At least Chain 138; names and explorer URLs correct.                                                                   |
| `get_token_list_url`         | `apiBaseUrl` or `tokenListUrl`                                      | `{ tokenListUrl, description }`                                               | URL is your API’s token-list endpoint (e.g. `…/api/v1/report/token-list`).                                             |
| `get_token_list`             | `apiBaseUrl` or `tokenListUrl`; optional `chainId`                  | `{ tokens: [ … ] }` (Uniswap-style)                                           | Each token has **logoURI**; list usable as MetaMask token list.                                                        |
| `get_oracles`                | `apiBaseUrl`; optional `chainId`                                    | `{ version, chains: [ … oracles ] }`                                          | Oracles for 138 (and others) if configured.                                                                            |
| `show_dynamic_info`          | `apiBaseUrl` or `networksUrl` / `tokenListUrl`                      | MetaMask dialog                                                               | Dialog shows networks and token list URL; no “pass apiBaseUrl” error.                                                  |
| `get_market_summary`         | `apiBaseUrl`; optional `chainId`                                    | `{ tokens: [ { symbol, name, address, market?: { priceUsd, volume24h } } ] }` | Tokens and optional prices; no error or empty when API is up.                                                          |
| `show_market_data`           | `apiBaseUrl`; optional `chainId`                                    | MetaMask dialog                                                               | “Market data (Chain 138)” (or chosen chain) with token symbols and prices.                                             |
| `get_bridge_routes`          | `apiBaseUrl` or `bridgeListUrl`                                     | `{ routes, chain138Bridges?, … }`                                             | CCIP (WETH9/WETH10) and, if configured, Trustless routes.                                                              |
| `show_bridge_routes`         | `apiBaseUrl` or `bridgeListUrl`                                     | MetaMask dialog                                                               | Dialog lists bridge routes.                                                                                            |
| `get_swap_quote`             | `apiBaseUrl`, `tokenIn`, `tokenOut`, `amountIn`; optional `chainId` | `{ amountOut?, error?, poolAddress? }`                                        | When pool exists: `amountOut` present; when not: `error` or null amountOut.                                            |
| `show_swap_quote`            | Same as `get_swap_quote`                                            | MetaMask dialog                                                               | Dialog shows quote or “no quote” message.                                                                              |

**Error cases to test:**

- [ ] `get_networks` without `apiBaseUrl` and without `networksUrl`: returns error message asking for params.
- [ ] `get_market_summary` with invalid or down API: returns `{ error, tokens: [] }` or similar; no uncaught exception.
- [ ] `show_*` methods without `apiBaseUrl` (when required): dialog or alert asks user to pass `apiBaseUrl`.

---

## 6. Companion site — every card and page

### 6.1 Home page (index)

| Element                             | Check                                                                                                                            |
| ----------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| Connect / Install Flask / Reconnect | Correct button or link visible; clicking triggers MetaMask.                                                                      |
| “Add Chain 138” / network card      | If present, invoking Snap to add network works.                                                                                  |
| **Market data** card                | “Show market data” opens Snap dialog; “Fetch market summary” shows tokens/prices below (when `GATSBY_SNAP_API_BASE_URL` is set). |
| **Bridge** card                     | “Show bridge routes” opens Snap dialog with routes.                                                                              |
| **Swap quote** card                 | Enter token In/Out (addresses) and amount; “Get quote” shows amountOut (or error); “Show quote in Snap” opens dialog.            |
| Notice / Send link                  | Link to “Send on Chain 138” is present and correct (e.g. `./send` or `/send`).                                                   |
| Footer                              | Version or build info if configured; no broken links.                                                                            |

If `GATSBY_SNAP_API_BASE_URL` is not set, Market/Bridge/Swap cards should show a clear message (e.g. “Set GATSBY_SNAP_API_BASE_URL”) instead of failing silently.

### 6.2 Send page (`/send`)

| Step                  | Check                                                                                                                     |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| Navigate              | Open `/send` (or path under your pathPrefix, e.g. `/snap/send`). Page loads.                                              |
| “Switch to Chain 138” | Click; MetaMask prompts to add/switch network; after approval, message confirms “Switched to Chain 138.”                  |
| Send form             | Enter recipient address and amount.                                                                                       |
| Send transaction      | Submit; MetaMask shows tx confirmation; after approval, tx is sent on Chain 138 and message or link to explorer is shown. |
| Back link             | “Back to Chain 138 Snap” (or similar) returns to home.                                                                    |

Use a test wallet with a small balance on Chain 138 to avoid real funds at risk.

---

## 7. Production-like test

Before publishing (or after publishing a version you intend to allowlist):

1. **Publish to npm** (or use the latest published version): `pnpm run publish:snap` (see [PUSH_AND_PUBLISH.md](../PUSH_AND_PUBLISH.md)).
2. **Build companion site with npm Snap:** Set `GATSBY_SNAP_ORIGIN=npm:chain138-snap` and `GATSBY_SNAP_API_BASE_URL` to your **production** token-aggregation URL (e.g. `https://explorer.d-bis.org` if API is proxied there). Build and serve (or deploy).
3. **Clean MetaMask Flask:** Remove the Snap if it was installed from local; optionally use a fresh profile.
4. **Install from production site:** Open the deployed companion site (e.g. https://explorer.d-bis.org/snap/). Connect and install the Snap — it should install from **npm** (no localhost). Verify Snap appears in Settings → Snaps as “Chain 138” with correct icon.
5. **Run through:** Repeat the RPC checks and companion site cards using the **production** API. Confirm market data, bridge, and swap quote work when the production API is up.
6. **Connected site:** In Snap settings, confirm the companion site origin is listed under “Connected sites” and can invoke the Snap.

---

## 8. Allowlist and directory submission

If you are submitting or updating the Snap in the MetaMask directory:

- [ ] Use [ALLOWLIST_FORM_FIELDS.md](../ALLOWLIST_FORM_FIELDS.md) for exact field values (Snap name, repo, npm, **version**).
- [ ] **Version:** Must match `packages/snap/package.json` and `snap.manifest.json` (e.g. 0.1.2).
- [ ] **Images:** Upload screenshots as required (companion site, Snap dialogs — see §4.5).
- [ ] **Demo video (optional):** Short walkthrough of install and use (Connect, add network, market data, bridge, swap quote, Send page).
- [ ] **Compliance:** [ALLOWLIST_SOURCE_AND_COMPLIANCE_CHECKLIST.md](../ALLOWLIST_SOURCE_AND_COMPLIANCE_CHECKLIST.md) — repo public, no key-management APIs, etc.

---

## 9. Recommendations and suggestions

- **Snapper / security:** If available, run [Snapper](https://docs.metamask.io/snaps/how-to/get-allowlisted/) (or the MetaMask security scanner) locally before publish.
- **Real wallet on Chain 138:** Test with a wallet that has a small balance on Chain 138 so in-wallet balance and the Send page reflect real behavior (and so you can verify token list and network icons in MetaMask).
- **Deployed companion site:** Test the full flow from the **deployed** companion site (e.g. https://explorer.d-bis.org/snap/) and from a different origin to confirm CORS and “Connected sites” behavior.
- **API health:** Before a release, confirm token-aggregation (or your API) is up and that `/api/v1/networks`, `/api/v1/report/token-list`, `/api/v1/bridge/routes`, `/api/v1/quote`, and `/api/v1/tokens` respond as expected. Document any env (e.g. `NETWORKS_JSON_URL`, `TOKEN_LIST_JSON_URL`) so operators can run the same checks.
- **Changelog / version:** Keep a short changelog (e.g. in README or CHANGELOG.md) and bump version deliberately; note any breaking changes for integrators (e.g. `apiBaseUrl` requirement).
- **Token list and logos:** When adding new tokens to the token-aggregation canonical list, always set **logoURI** (or `logoUrl` in spec) so MetaMask and the Snap never show a token without a logo.
- **Network icons:** When adding or changing chains in token-aggregation `networks.ts`, always set **iconUrls** and ensure URLs are stable and reachable (favicon or official chain logo).

---

## 10. Final sign-off checklist (before publish)

Use this as a single pass/fail before `pnpm run publish:snap`.

**Automatable (run `bash scripts/verify-pre-publish.sh`):** Build, unit tests, package contents, manifest/package version, Prettier check. Optional: `pnpm run test:e2e` (set `SKIP_E2E=1` to skip).

- [ ] **Build:** `pnpm run build` succeeds; manifest shasum is correct.
- [ ] **Tests:** `pnpm run test` passes; `pnpm run lint:misc --check` (Prettier) passes. *(Full `pnpm run lint` includes ESLint; repo may have existing ESLint rule warnings.)*
- [ ] **Snap package:** `dist/bundle.js`, `images/icon.svg`, `snap.manifest.json` present; `package.json` version and `files` correct.
- [ ] **Snap icon:** Icon displays correctly in MetaMask Snap list/detail.
- [ ] **Token list:** Every token from `/api/v1/report/token-list` has a valid **logoURI**; list-level logoURI set.
- [ ] **Networks:** Each network from `/api/v1/networks` has **iconUrls**; all URLs reachable.
- [ ] **RPC methods:** All methods in §5 tested; success and error paths as expected.
- [ ] **Companion site:** All cards (Market, Bridge, Swap) and Send page tested; links and messages correct.
- [ ] **Production-like:** Installed from npm and tested with production API (if applicable).
- [ ] **Allowlist:** If submitting/updating directory, form fields and screenshots ready (§8).

When all items are checked, the Snap is ready for publish and (optionally) directory submission.

---

**Related docs**

- **Script:** `scripts/verify-pre-publish.sh` — runs build, test, package contents, version check, Prettier. Use before publish.
- [TESTING_INSTRUCTIONS.md](../TESTING_INSTRUCTIONS.md) — RPC examples and E2E checklist.
- [E2E_PREPARATION.md](../E2E_PREPARATION.md) — Token-aggregation and env setup.
- [MANUAL_E2E_CHECKLIST.md](../MANUAL_E2E_CHECKLIST.md) — Short manual checklist.
- [CHAIN138_SNAP_TROUBLESHOOTING.md](CHAIN138_SNAP_TROUBLESHOOTING.md) — Balance, swap, and API issues.
- [PUSH_AND_PUBLISH.md](../PUSH_AND_PUBLISH.md) — Version bump and npm publish.
- [ALLOWLIST_FORM_FIELDS.md](../ALLOWLIST_FORM_FIELDS.md) — Directory form and images.
