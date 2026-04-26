# Chain 138 Snap — Integrator guide

Use this Snap from your dApp to provide Chain 138 (and ALL Mainnet) network params, token list, market data, swap quotes, and bridge routes (CCIP and Trustless) inside MetaMask.

## Production Snap ID

After the Snap is published to npm, use:

**`npm:chain138-snap`**

Example (wallet_invokeSnap):

```js
await ethereum.request({
  method: 'wallet_invokeSnap',
  params: {
    snapId: 'npm:chain138-snap',
    request: { method: 'hello' },
  },
});
```

## Required: apiBaseUrl

For **market data**, **swap quotes**, and **bridge routes**, the dApp must pass `apiBaseUrl` (your token-aggregation service base URL) in the request params:

```js
params: {
  apiBaseUrl: 'https://your-token-aggregation-api.com',
  // optional: chainId (default 138), tokenIn, tokenOut, amountIn for swap, etc.
}
```

## Optional URL params

You can pass these instead of or in addition to `apiBaseUrl` for specific data:

| Param           | Purpose               | Used by RPCs                              |
| --------------- | --------------------- | ----------------------------------------- |
| `networksUrl`   | JSON URL for networks | `get_networks`, `get_chain138_config`     |
| `tokenListUrl`  | JSON URL for tokens   | `get_token_list`, `get_token_list_url`    |
| `bridgeListUrl` | JSON URL for bridge   | `get_bridge_routes`, `show_bridge_routes` |

## Companion site env

For the companion site (this repo’s `packages/site`):

- **Development:** Uses local Snap; no `SNAP_ORIGIN` needed (defaults to local).
- **Production:** Set `SNAP_ORIGIN=npm:chain138-snap` and `GATSBY_SNAP_API_BASE_URL` to your token-aggregation base URL so the site uses the published Snap and passes `apiBaseUrl` to it.

## RPC methods

See [TESTING_INSTRUCTIONS.md](TESTING_INSTRUCTIONS.md) for the full list: `hello`, `get_networks`, `get_chain138_config`, `get_chain138_market_chains`, `get_token_list`, `get_token_list_url`, `get_oracles`, `show_dynamic_info`, `get_market_summary`, `get_current_price`, `get_historical_price`, `get_pricing_context`, `show_market_data`, `get_bridge_routes`, `show_bridge_routes`, `get_swap_quote`, `show_swap_quote`.
