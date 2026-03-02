# Integration and Testing

How to build, integrate, and test the MetaMask dual-chain provider, explorer config, token-aggregation API, and Chain 138 Snap. **Default package manager: pnpm.**

---

## Run all (pnpm)

From the repo root or `metamask-integration/`:

```bash
cd metamask-integration
pnpm run run-all
```

Runs: (1) full integration script (provider test + config validation), (2) token-aggregation `pnpm install` + `pnpm run build`, (3) explorer frontend `pnpm install` + `pnpm run build`, (4) Chain 138 Snap install + build (Snap template uses yarn internally).

---

## 1. Provider (Node) integration test

From the repo root (or `metamask-integration/`):

```bash
cd metamask-integration/provider
pnpm exec node test-integration.mjs
# or: node test-integration.mjs
```

Tests chains, tokens, wallet exports, and oracles without `window.ethereum`. Expect: **4 passed, 0 failed**.

---

## 2. Full integration script

Runs provider test + validates explorer config JSONs + optional Explorer API and token-aggregation API:

```bash
cd metamask-integration
pnpm run test:integration
# or: ./scripts/integration-test-all.sh
```

**Optional env (for live API checks):**

- `EXPLORER_API_URL` – e.g. `http://localhost:8080` (explorer backend)
- `TOKEN_AGGREGATION_URL` – e.g. `http://localhost:3000` (token-aggregation service)

Config files validated from repo: `docs/04-configuration/metamask/DUAL_CHAIN_NETWORKS.json`, `DUAL_CHAIN_TOKEN_LIST.tokenlist.json`.

---

## 3. Explorer API (config endpoints)

Explorer backend serves:

- `GET /api/config/networks` – Chain 138 + Ethereum Mainnet + ALL Mainnet params
- `GET /api/config/token-list` – Uniswap token list format

To test against a running explorer:

```bash
export EXPLORER_API_URL=http://localhost:8080
./scripts/integration-test-all.sh
```

Explorer backend requires DB; see `explorer-monorepo/backend/` for build/run.

---

## 4. Token-aggregation API

Token-aggregation service (Chain 138 + ALL Mainnet) exposes:

**Note:** The service may have existing TypeScript build issues in `canonical-tokens.ts`; the REST API is documented and can be tested when the service is run (e.g. via Docker or with DB).

- `GET /api/v1/chains` – supported chains
- `GET /api/v1/tokens?chainId=138` – tokens and market data
- See `smom-dbis-138/services/token-aggregation/docs/REST_API_REFERENCE.md`

To test when the service is running (with DB):

```bash
export TOKEN_AGGREGATION_URL=http://localhost:3000
./scripts/integration-test-all.sh
```

---

## 5. Provider E2E (manual, browser)

Open `metamask-integration/examples/provider-e2e.html` **via a local server** (e.g. `npx serve metamask-integration/examples` or your app) with MetaMask installed.

- **Add chains** – adds Chain 138, Ethereum Mainnet, ALL Mainnet
- **Switch chain** – 138 / 1 / 651940
- **List tokens** – tokens from provider for current chain
- **ETH/USD price** – oracle price (requires ethers; loads from esm.sh if needed)

---

## 6. Chain 138 Snap

Snap provides:

- `get_chain138_config` – Chain 138 params for `wallet_addEthereumChain`
- `get_chain138_market_chains` – fetches `GET {apiBaseUrl}/api/v1/chains` (pass token-aggregation base URL)
- `hello` – demo dialog

**Build and run (from repo root):**

```bash
cd metamask-integration/chain138-snap
yarn install
yarn build
yarn start
```

Then install the Snap in MetaMask Flask using the provided site (e.g. `http://localhost:8000`). Invoke from a dapp:

```js
await ethereum.request({
  method: 'wallet_invokeSnap',
  params: {
    snapId: 'YOUR_SNAP_ID',
    request: { method: 'get_chain138_config' },
  },
});
```

---

## Summary

| Item | Command / location (pnpm default) |
|------|------------------------------------|
| **Run all** | `cd metamask-integration && pnpm run run-all` |
| Provider test | `cd provider && pnpm exec node test-integration.mjs` |
| Full integration | `pnpm run test:integration` or `./scripts/integration-test-all.sh` |
| Explorer config | Validated by script; optional `EXPLORER_API_URL` |
| Token-aggregation | `cd smom-dbis-138/services/token-aggregation && pnpm install && pnpm run build`; optional `TOKEN_AGGREGATION_URL` in script |
| Provider E2E | Serve `examples/provider-e2e.html`, use MetaMask |
| Snap | `chain138-snap`: pnpm install, pnpm run build, pnpm run start (template uses yarn internally); install in Flask |
