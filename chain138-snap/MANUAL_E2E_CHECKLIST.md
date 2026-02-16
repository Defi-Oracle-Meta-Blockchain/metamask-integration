# Manual E2E checklist (MetaMask Flask + companion site)

Use this checklist to complete **manual** E2E verification. Covers Snap install, all RPC methods, and companion site cards.

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

*(Use browser console and `wallet_invokeSnap` as in TESTING_INSTRUCTIONS.md.)*

---

## 3. Companion site cards

- [ ] **Market data:** "Show market data" opens Snap dialog; "Fetch market summary" shows tokens/prices
- [ ] **Bridge:** "Show bridge routes" opens Snap dialog with CCIP routes
- [ ] **Swap quote:** Enter token In/Out addresses and amount (raw); "Get quote" shows amountOut; "Show quote in Snap" opens dialog

---

When all items are checked, manual E2E (snap-9 and snap-10) is complete.
