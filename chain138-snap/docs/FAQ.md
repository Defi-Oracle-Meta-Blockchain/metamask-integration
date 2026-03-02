# Chain 138 Snap — FAQ

Frequently asked questions about the Chain 138 Snap (MetaMask).

---

## General

### What is the Chain 138 Snap?

A MetaMask Snap that adds **Chain 138** (DeFi Oracle Meta Mainnet) and **ALL Mainnet** (651940) support inside MetaMask: network parameters, token list, market data (USD prices), swap quotes, and bridge routes (CCIP and Trustless). It uses a token-aggregation (or compatible) API that you configure.

### Why use this Snap?

MetaMask supports Chain 138 as a custom EVM network, but native **Swaps**, **Portfolio Bridge**, and **USD pricing** do not include Chain 138. This Snap provides in-wallet swap quotes, bridge routes, and market data by calling your API, so users get feature parity without waiting for upstream support.

### What is the Snap ID?

**Production:** `npm:chain138-snap` (after installing from npm or the MetaMask Snaps Directory).

**Development:** `local:http://localhost:8000` when running the dev server.

---

## Installation and usage

### How do I install the Snap?

1. Install [MetaMask](https://metamask.io/) (or [MetaMask Flask](https://metamask.io/flask/) for development).
2. From a dApp or the companion site, connect and add the Snap using the ID `npm:chain138-snap`.

### Do I need MetaMask Flask?

- **Production:** No. Once the Snap is allowlisted, it installs in standard MetaMask.
- **Development:** Yes, for testing before allowlisting. Use [MetaMask Flask](https://metamask.io/flask/).

### Why do market data, swap quote, and bridge routes not work?

Those features require the dApp to pass **`apiBaseUrl`** (your token-aggregation service base URL) when invoking the Snap. Without it, the Snap cannot fetch data. See [INTEGRATORS.md](../INTEGRATORS.md).

### Can I use my own API or JSON URLs?

Yes. You can pass:

- **`apiBaseUrl`** — base URL of a token-aggregation–compatible API (networks, token list, bridge, quote endpoints).
- **`networksUrl`** — direct URL to a networks JSON (overrides API for networks).
- **`tokenListUrl`** — direct URL to a token list JSON.
- **`bridgeListUrl`** — direct URL to a bridge routes JSON.

See [INTEGRATORS.md](../INTEGRATORS.md) and [TESTING_INSTRUCTIONS.md](../TESTING_INSTRUCTIONS.md).

---

## Development

### How do I run the Snap locally?

From the repo root: `pnpm run start`. The companion site and Snap are served at http://localhost:8000. Use MetaMask Flask and connect to that URL.

### How do I run tests?

- **Unit (Jest):** `pnpm run test`
- **E2E (Playwright):** `pnpm run test:e2e` (run `npx playwright install` once)

See [TESTING_INSTRUCTIONS.md](../TESTING_INSTRUCTIONS.md) for full manual E2E.

### The companion site shows "Set GATSBY_SNAP_API_BASE_URL"

Set `GATSBY_SNAP_API_BASE_URL` in `packages/site/.env` (copy from `.env.production.dist`) to your token-aggregation API base URL so the site can pass `apiBaseUrl` to the Snap. Restart the dev server after changing env.

### How do I publish a new version?

1. Bump version in `packages/snap/package.json`.
2. From repo root: `pnpm run build` then `pnpm run publish:snap` (see [PUSH_AND_PUBLISH.md](../PUSH_AND_PUBLISH.md)).
3. Push to GitHub. If the Snap is allowlisted, submit a version update via the [MetaMask update form](https://docs.metamask.io/snaps/how-to/get-allowlisted/#5-update-your-snap).

---

## Permissions and security

### What permissions does the Snap use?

- **snap_dialog** — show dialogs (e.g. bridge routes, market data).
- **endowment:rpc** (dapps: true) — handle RPC from dApps.
- **endowment:network-access** — fetch data from the configured API/URLs.

No key-management or account APIs are used. See [SECURITY.md](../SECURITY.md) and `packages/snap/snap.manifest.json`.

### Is an audit required for allowlisting?

No. The Snap does not use key-management APIs, so a third-party audit is not required for the MetaMask Snaps Directory. See [ALLOWLIST_SOURCE_AND_COMPLIANCE_CHECKLIST.md](../ALLOWLIST_SOURCE_AND_COMPLIANCE_CHECKLIST.md).

---

## RPC methods

### What RPC methods are available?

See the table in [packages/snap/README.md](../packages/snap/README.md) or [TESTING_INSTRUCTIONS.md](../TESTING_INSTRUCTIONS.md). Summary: `hello`, `get_networks`, `get_chain138_config`, `get_chain138_market_chains`, `get_token_list`, `get_token_list_url`, `get_oracles`, `show_dynamic_info`, `get_market_summary`, `show_market_data`, `get_bridge_routes`, `show_bridge_routes`, `get_swap_quote`, `show_swap_quote`.

### How do I call the Snap from my dApp?

Use `wallet_requestSnaps` to install and `wallet_invokeSnap` to call methods. Example in [INTEGRATORS.md](../INTEGRATORS.md) and [packages/snap/README.md](../packages/snap/README.md).

---

## Troubleshooting

### Snap not appearing in MetaMask Flask

- Ensure the dev server is running on port 8000 and you opened http://localhost:8000.
- Check the browser console for errors and refresh the page.

### API calls failing (CORS, 404)

- Ensure your token-aggregation API allows the Snap/site origin in CORS.
- Verify `apiBaseUrl` is correct (no trailing slash) and the endpoints (e.g. `/api/v1/networks`, `/api/v1/report/token-list`) exist and return valid JSON.

### Permission errors

- Confirm `snap.manifest.json` includes `endowment:network-access` if you call APIs. Reinstall the Snap after changing the manifest.

For more, see the **Troubleshooting** section in [TESTING_INSTRUCTIONS.md](../TESTING_INSTRUCTIONS.md).
