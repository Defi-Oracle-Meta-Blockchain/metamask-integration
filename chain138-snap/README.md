# Chain 138 Snap (MetaMask)

A MetaMask Snap that adds **both** supported blockchains inside MetaMask:

| Blockchain      | Chain ID | Name                     |
| --------------- | -------- | ------------------------ |
| **Chain 138**   | 138      | DeFi Oracle Meta Mainnet |
| **ALL Mainnet** | 651940   | ALL Mainnet              |

The Snap provides **network params**, **token list**, **market data** (USD prices), **swap quotes**, and **CCIP bridge routes** for these chains. It reads configuration from a **token-aggregation** (or compatible) API that you supply via `apiBaseUrl` or optional URL params.

**Why this Snap:** MetaMask supports Chain 138 as a custom EVM network, but native **Swaps**, **Portfolio Bridge**, and **USD pricing** do not include Chain 138 or ALL Mainnet. This Snap gives in-wallet swap quotes, bridge routes, and market data by calling your token-aggregation API, so users get feature parity on both blockchains without waiting for upstream support.

---

## Features (both blockchains)

- **Networks & config** — EIP-3085 params for Chain 138 and ALL Mainnet (`get_networks`, `get_chain138_config`, `get_chain138_market_chains`).
- **Token list** — By chain; optional `chainId` (138 or 651940) for `get_token_list` / `get_token_list_url`.
- **Market data** — Tokens and USD prices; in-Snap dialog via `show_market_data`.
- **Bridge routes** — CCIP (WETH9/WETH10) and Trustless (Lockbox) routes to Ethereum Mainnet; dialog via `show_bridge_routes`.
- **Swap quote** — Quote for Chain 138; dialog via `show_swap_quote`.
- **Send (Chain 138)** — Companion site **Send** page (`/send`) so users can send ETH on Chain 138 without using MetaMask’s in-wallet Send button (which can error with “No XChain Swaps native asset found” on custom chains).
- **Oracles & dynamic info** — API config and in-Snap dialog (`get_oracles`, `show_dynamic_info`).

Every method and parameter is documented with **tables and diagrams** in **[docs/FEATURES.md](docs/FEATURES.md)** (method matrix, params, response shapes, request flow).

---

## Snap ID

**Production:** `npm:chain138-snap`

Install from a dApp or the [companion site](https://github.com/bis-innovations/chain138-snap) by connecting with MetaMask and adding the Snap with this ID.

---

## Integrators

- **Snap ID:** `npm:chain138-snap`
- **Market data, swap quote, bridge routes** require the dApp to pass **`apiBaseUrl`** (your token-aggregation base URL) when invoking the Snap.
- Optional overrides: `networksUrl`, `tokenListUrl`, `bridgeListUrl` (see [INTEGRATORS.md](INTEGRATORS.md)).
- Companion site: set `GATSBY_SNAP_API_BASE_URL` for the demo; set `SNAP_ORIGIN=npm:chain138-snap` for production so the site uses the published Snap.

---

## Testing before publish

For **thorough pre-publish testing** (build, all RPC methods, **logos/images** for chain and tokens, companion site, Send page, production-like test, and recommendations), see **[docs/PRE_PUBLISH_TESTING.md](docs/PRE_PUBLISH_TESTING.md)**. Quick manual E2E: [MANUAL_E2E_CHECKLIST.md](MANUAL_E2E_CHECKLIST.md) and [TESTING_INSTRUCTIONS.md](TESTING_INSTRUCTIONS.md).

---

## Troubleshooting (balance, swap, data not showing)

If **main balance or USD is not showing**, **Swap is malfunctioning**, or **historical/market data** does not load, see **[docs/CHAIN138_SNAP_TROUBLESHOOTING.md](docs/CHAIN138_SNAP_TROUBLESHOOTING.md)**. Summary:

- **$0.00 / no conversion rate:** MetaMask has no price feed for Chain 138; use Snap “Show market data” on the companion site or accept quantity-only in the wallet.
- **In-wallet Swap fails:** MetaMask Swap does not support Chain 138; use [Send on Chain 138](https://explorer.d-bis.org/snap/send) and swap quotes from the Snap companion site.
- **Snap market/swap/bridge errors:** Ensure `GATSBY_SNAP_API_BASE_URL` points to a host that serves the token-aggregation API (`/api/v1/networks`, `/api/v1/tokens`, `/api/v1/quote`, etc.); see the troubleshooting doc and [FAQ](docs/FAQ.md).

---

## Getting started

**Clone this repo** and run:

```shell
pnpm install && pnpm start
```

Or with Yarn: `yarn install && yarn start`. See [PACKAGE_MANAGER.md](PACKAGE_MANAGER.md).

The companion site and Snap are served at **http://localhost:8000**. Use [MetaMask Flask](https://metamask.io/flask/) for development; once the Snap is allowlisted, standard MetaMask can install it.

---

## Documentation

| Link                                               | Description                                                                                  |
| -------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| [docs/README.md](docs/README.md)                   | Documentation index                                                                          |
| [docs/FEATURES.md](docs/FEATURES.md)               | **All functions and features** — RPC methods, params, both blockchains, tables, flow diagram |
| [INTEGRATORS.md](INTEGRATORS.md)                   | Integrator guide (Snap ID, apiBaseUrl, RPC list)                                             |
| [TESTING_INSTRUCTIONS.md](TESTING_INSTRUCTIONS.md) | Development and E2E testing                                                                  |
| [docs/FAQ.md](docs/FAQ.md)                         | FAQ                                                                                          |

---

## Contributing

- **Lint:** `pnpm run lint` / `pnpm run lint:fix`
- **Test:** `pnpm run test` (Snap unit tests), `pnpm run test:e2e` (Playwright; run `npx playwright install` once)
- See [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md) and [E2E_PREPARATION.md](E2E_PREPARATION.md) for full setup.

Scripts are disabled by default (LavaMoat). If needed: `pnpm run allow-scripts` and enable the package in the `lavamoat.allowScripts` section of `package.json`. See [@lavamoat/allow-scripts](https://github.com/LavaMoat/LavaMoat/tree/main/packages/allow-scripts).

---

This Snap targets the **latest stable MetaMask Snap SDK** (`@metamask/snaps-sdk`).
