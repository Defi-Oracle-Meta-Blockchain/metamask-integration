# chain138-snap

**Chain 138 Snap** adds [DeFi Oracle Meta Mainnet](https://chainlist.org/chain/138) (ChainID 138) and **ALL Mainnet** (651940) support inside MetaMask: network params, token list, market data, swap quotes, and bridge routes (CCIP and Trustless).

MetaMask already supports Chain 138 as a custom EVM network, but native **Swaps**, **Portfolio Bridge**, and **USD pricing** do not include Chain 138. This Snap provides in-wallet swap quotes, bridge routes, and market data by calling your token-aggregation (or compatible) API.

## Install

1. Install [MetaMask](https://metamask.io/) (extension or mobile).
2. From a dApp or the [companion site](https://github.com/bis-innovations/chain138-snap), connect and add the Snap using the ID below.

**Snap ID:** `npm:chain138-snap`

## Usage

dApps invoke the Snap via the MetaMask provider:

```javascript
// Connect / install the Snap (your dApp typically does this once)
await ethereum.request({
  method: 'wallet_requestSnaps',
  params: {
    'npm:chain138-snap': {},
  },
});

// Call a method (e.g. get networks or market data)
const result = await ethereum.request({
  method: 'wallet_invokeSnap',
  params: {
    snapId: 'npm:chain138-snap',
    request: {
      method: 'get_networks',
      params: { apiBaseUrl: 'https://your-token-aggregation-api.com' },
    },
  },
});
```

For **market data**, **swap quotes**, and **bridge routes**, the dApp must pass `apiBaseUrl` (your token-aggregation service base URL) in the request params. Optional URL params: `networksUrl`, `tokenListUrl`, `bridgeListUrl`.

### RPC methods

| Method                                     | Description                                                    |
| ------------------------------------------ | -------------------------------------------------------------- |
| `hello`                                    | Basic test; returns a greeting.                                |
| `get_networks`                             | Full EIP-3085 chain params (Chain 138, Ethereum, ALL Mainnet). |
| `get_chain138_config`                      | Chain 138 config from API.                                     |
| `get_chain138_market_chains`               | Market chains list.                                            |
| `get_token_list` / `get_token_list_url`    | Token list (optional `chainId`).                               |
| `get_oracles`                              | Oracles config.                                                |
| `show_dynamic_info`                        | In-Snap dialog with networks and token list URL.               |
| `get_market_summary` / `show_market_data`  | Tokens and USD prices.                                         |
| `get_current_price`                        | Current USD price snapshot for one token.                      |
| `get_historical_price`                     | Point-in-time USD valuation for one token at a timestamp.      |
| `get_pricing_context`                      | Combined current and historical pricing response.              |
| `get_bridge_routes` / `show_bridge_routes` | CCIP and Trustless bridge routes.                              |
| `get_swap_quote` / `show_swap_quote`       | Swap quote (requires `tokenIn`, `tokenOut`, `amountIn`).       |

## Repository and docs

- **Source:** [github.com/bis-innovations/chain138-snap](https://github.com/bis-innovations/chain138-snap)
- **Integrator guide:** [INTEGRATORS.md](https://github.com/bis-innovations/chain138-snap/blob/main/INTEGRATORS.md) (Snap ID, `apiBaseUrl`, optional URLs)
- **Testing / publishing:** [TESTING_INSTRUCTIONS.md](https://github.com/bis-innovations/chain138-snap/blob/main/TESTING_INSTRUCTIONS.md), [PUSH_AND_PUBLISH.md](https://github.com/bis-innovations/chain138-snap/blob/main/PUSH_AND_PUBLISH.md)

## License

MIT-0 OR Apache-2.0
