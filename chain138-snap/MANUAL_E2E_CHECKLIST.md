# Manual E2E checklist (MetaMask Flask + companion site)

Use this checklist to complete **manual** E2E verification. Covers Snap install, all RPC methods, and companion site cards.

**For thorough pre-publish testing** (logos/images, every asset, production-like test, recommendations): use **[docs/PRE_PUBLISH_TESTING.md](docs/PRE_PUBLISH_TESTING.md)**.

## Prerequisites

- [ ] MetaMask Flask installed: https://metamask.io/flask/
- [ ] Snap dev server: `pnpm run start` in `chain138-snap` (or `pnpm start` from repo root)
- [ ] For API-dependent features: token-aggregation service running; set `GATSBY_SNAP_API_BASE_URL` in `packages/site/.env` (copy from `.env.production.dist`)

---

## 1. Install Snap

- [ ] Open http://localhost:8000 in the browser
- [ ] Click **Connect** and approve Snap installation in MetaMask Flask

---

## 2. RPC methods (pass `apiBaseUrl` or optional URLs where required)

- [ ] `hello`
- [ ] `get_networks` (apiBaseUrl or networksUrl)
- [ ] `get_chain138_config` (apiBaseUrl or networksUrl)
- [ ] `get_chain138_market_chains` (apiBaseUrl)
- [ ] `get_token_list`, `get_token_list_url` (apiBaseUrl or tokenListUrl; optional chainId)
- [ ] `get_oracles` (apiBaseUrl), `show_dynamic_info` (apiBaseUrl or networksUrl/tokenListUrl)
- [ ] `get_market_summary`, `show_market_data` (apiBaseUrl; optional chainId)
- [ ] `get_bridge_routes`, `show_bridge_routes` (apiBaseUrl or bridgeListUrl)
- [ ] `get_swap_quote`, `show_swap_quote` (apiBaseUrl, tokenIn, tokenOut, amountIn; optional chainId)

_(Use browser console and `wallet_invokeSnap` as in TESTING_INSTRUCTIONS.md.)_

---

## 3. Companion site cards

- [ ] **Market data:** "Show market data" opens Snap dialog; "Fetch market summary" shows tokens/prices
- [ ] **Bridge:** "Show bridge routes" opens Snap dialog with CCIP and Trustless routes
- [ ] **Swap quote:** Enter token In/Out addresses and amount (raw); "Get quote" shows amountOut; "Show quote in Snap" opens dialog

---

## 4. Logos and images (pre-publish)

- [ ] Snap icon shows in MetaMask (Settings → Snaps → Chain 138).
- [ ] Token list from API: every token has `logoURI`; list has list-level `logoURI` (see PRE_PUBLISH_TESTING.md §4.3).
- [ ] Networks from API: each network has `iconUrls` and URLs resolve (see PRE_PUBLISH_TESTING.md §4.4).

---

When all items are checked, manual E2E (snap-9 and snap-10) is complete. Before publishing, complete the full [PRE_PUBLISH_TESTING.md](docs/PRE_PUBLISH_TESTING.md) sign-off.
