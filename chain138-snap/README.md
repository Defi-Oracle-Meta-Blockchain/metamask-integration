# Chain 138 Snap (MetaMask)

This Snap provides **Chain 138** (DeFi Oracle Meta Mainnet) and **ALL Mainnet** (651940) support in MetaMask: network params, token list, market data (prices), swap quotes, and CCIP bridge routes. It reads configuration from a **token-aggregation** (or compatible) API.

**Why we built it:** MetaMask already supports Chain 138 as a custom EVM network (add via RPC), but native **Swaps**, **Portfolio Bridge**, and **USD pricing** do not include Chain 138 (Consensys-controlled). No public Snap existed for swap/bridge/pricing on 138. This Snap gives in-wallet swap quotes, bridge routes, and market data by calling our APIs, so users get feature parity without waiting for Consensys. See [docs/04-configuration/CHAIN138_WALLET_ECOSYSTEM_AND_RATIONALE.md](../../docs/04-configuration/CHAIN138_WALLET_ECOSYSTEM_AND_RATIONALE.md#2-why-we-created-the-metamask-snap) for full rationale.

For detailed development and testing, see [TESTING_INSTRUCTIONS.md](TESTING_INSTRUCTIONS.md). For implementation phases and backend APIs, see [docs/04-configuration/metamask/SNAP_IMPLEMENTATION_ROADMAP.md](../../docs/04-configuration/metamask/SNAP_IMPLEMENTATION_ROADMAP.md) in the repo root.

**Integrators:** Production Snap ID: **`npm:chain138-snap`**. Market data, swap quote, and bridge route features require the dApp to pass `apiBaseUrl` (the token-aggregation service base URL) when invoking the Snap. You may also pass optional URLs: `networksUrl`, `tokenListUrl`, `bridgeListUrl`. Set `GATSBY_SNAP_API_BASE_URL` on the companion site so the demo page works. For production, set `SNAP_ORIGIN=npm:chain138-snap` in the site env so the companion uses the published Snap.

This Snap targets the **latest stable MetaMask Snap SDK** (`@metamask/snaps-sdk`).

## Snaps is pre-release software

To interact with (your) Snaps, you will need to install [MetaMask Flask](https://metamask.io/flask/),
a canary distribution for developers that provides access to upcoming features.

## Getting Started

Clone the template-snap repository [using this template](https://github.com/MetaMask/template-snap-monorepo/generate)
and set up the development environment.

**Default (pnpm):**

```shell
pnpm install && pnpm start
```

**Alternative (yarn):**

```shell
yarn install && yarn start
```

See [PACKAGE_MANAGER.md](PACKAGE_MANAGER.md) for details.

## Cloning

This repository contains GitHub Actions that you may find useful, see
`.github/workflows` and [Releasing & Publishing](https://github.com/MetaMask/template-snap-monorepo/edit/main/README.md#releasing--publishing)
below for more information.

If you clone or create this repository outside the MetaMask GitHub organization,
you probably want to run `./scripts/cleanup.sh` to remove some files that will
not work properly outside the MetaMask GitHub organization.

If you don't wish to use any of the existing GitHub actions in this repository,
simply delete the `.github/workflows` directory.

## Contributing

### Testing and Linting

**pnpm (default):** `pnpm run test`, `pnpm run lint`, `pnpm run lint:fix`  
**yarn:** `yarn test`, `yarn lint`, `yarn lint:fix`

- **Unit tests:** `pnpm run test` (Snap Jest tests).
- **E2E (Playwright):** `pnpm run test:e2e` — starts the dev server if needed and runs companion-site E2E tests. First time run `npx playwright install`. See [TESTING_INSTRUCTIONS.md](TESTING_INSTRUCTIONS.md) and [E2E_PREPARATION.md](E2E_PREPARATION.md) for full manual E2E (MetaMask Flask) and token-aggregation setup.

### Using NPM packages with scripts

Scripts are disabled by default for security reasons. If you need to use NPM
packages with scripts, run **pnpm run allow-scripts** (or **yarn allow-scripts auto**) and enable the
script in the `lavamoat.allowScripts` section of `package.json`.

See the documentation for [@lavamoat/allow-scripts](https://github.com/LavaMoat/LavaMoat/tree/main/packages/allow-scripts)
for more information.
