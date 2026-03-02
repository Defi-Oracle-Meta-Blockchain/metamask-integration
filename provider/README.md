# MetaMask Multi-Chain Provider

Connect **MetaMask** and other Web3 providers to **ChainID 138** (DeFi Oracle Meta Mainnet), **Ethereum Mainnet** (1), and **ALL Mainnet** (651940). Includes chain configs, combined token list, and oracle helpers so tokens and price feeds work across chains.

## Features

- **Multi-chain**: Add and switch between Chain 138, Ethereum Mainnet, and ALL Mainnet in one flow.
- **Token list**: All tokens from all three chains (Chain 138: WETH, WETH10, cUSDT, cUSDC, ETH/USD oracle; Mainnet: WETH, USDT, USDC, DAI, ETH/USD oracle; ALL Mainnet: USDC).
- **Oracles**: Read ETH/USD from Chain 138 oracle and from Chainlink on Mainnet so dApps can display USD values.

## Installation

Use as a local module (no publish required):

```bash
# From your app (e.g. metamask-integration/examples/react-example)
npm install ethers   # peer dependency for getEthUsdPrice
```

Import from the provider path:

```javascript
import { addChainsToWallet, switchChain, getEthUsdPrice, getTokensByChain } from '../provider/index.js'
```

Or copy the `provider/` folder into your project and import from `./provider`.

## Quick Start

### 1. Add both chains to MetaMask

```javascript
import { addChainsToWallet } from './provider/index.js'

const ethereum = window.ethereum
if (ethereum) {
  const result = await addChainsToWallet(ethereum)
  console.log('Added:', result.added, 'Skipped:', result.skipped, 'Errors:', result.errors)
}
```

### 2. Switch chain

```javascript
import { switchChain, ensureChain } from './provider/index.js'

await switchChain(window.ethereum, 138)   // DeFi Oracle Meta Mainnet
await switchChain(window.ethereum, 1)     // Ethereum Mainnet

// Or ensure current chain (switch if needed, add if missing)
await ensureChain(window.ethereum, 138)
```

### 3. Add a token to the wallet

```javascript
import { addTokenToWallet, getToken, getTokensByChain } from './provider/index.js'

const tokens138 = getTokensByChain(138)
for (const token of tokens138) {
  if (token.tags?.includes('oracle')) continue
  await addTokenToWallet(window.ethereum, token)
}

// Or a single token by address
const weth = getToken(138, '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2')
if (weth) await addTokenToWallet(window.ethereum, weth)
```

### 4. Read oracle price (ETH/USD)

Requires `ethers` v6. Works on both Chain 138 and Mainnet.

```javascript
import { ethers } from 'ethers'
import { getEthUsdPrice } from './provider/index.js'

const provider = new ethers.BrowserProvider(window.ethereum)
const chainId = (await provider.getNetwork()).chainId

const result = await getEthUsdPrice(provider, Number(chainId))
if (result) {
  console.log('ETH/USD:', result.price, 'Updated:', result.updatedAt)
}
```

## API

| Export | Description |
|--------|-------------|
| `CHAINS`, `CHAIN_138`, `CHAIN_MAINNET` | Chain params for `wallet_addEthereumChain` |
| `getChainById(chainIdDecimal)`, `getChainByHex(chainIdHex)` | Look up chain config |
| `addChainsToWallet(ethereum, options?)` | Add Chain 138 and/or Mainnet |
| `switchChain(ethereum, chainIdDecimal)` | Switch to chain (adds if missing) |
| `ensureChain(ethereum, chainIdDecimal)` | Switch to chain if not already on it |
| `addTokenToWallet(ethereum, token)` | Add token via `wallet_watchAsset` |
| `TOKEN_LIST`, `getTokensByChain(chainId)`, `getToken(chainId, address)` | Token list for both chains |
| `TOKEN_LIST_URL` | URL/path to host the combined token list JSON |
| `getEthUsdPrice(provider, chainId)` | Read ETH/USD from oracle (needs ethers) |
| `ORACLES_CHAIN_138`, `ORACLES_MAINNET`, `getOracleConfig(chainId)` | Oracle addresses and config |

## Config files

- **Networks**: `docs/04-configuration/metamask/DUAL_CHAIN_NETWORKS.json` — both chain params.
- **Token list**: `docs/04-configuration/metamask/DUAL_CHAIN_TOKEN_LIST.tokenlist.json` — tokens for Chain 138 and Mainnet.

Host the token list at a public URL and set your app’s token list URL to it so MetaMask can fetch the list (or use the inline `TOKEN_LIST` / `getTokensByChain` in your UI).

## Downloads

| Asset | In-repo path | Use |
|-------|--------------|-----|
| **Multi-chain networks** | `docs/04-configuration/metamask/DUAL_CHAIN_NETWORKS.json` | `wallet_addEthereumChain` params for Chain 138, Ethereum Mainnet, and ALL Mainnet. If bundled: `config/DUAL_CHAIN_NETWORKS.json`. |
| **Dual-chain token list** | `docs/04-configuration/metamask/DUAL_CHAIN_TOKEN_LIST.tokenlist.json` | MetaMask token list URL; Uniswap token list format. If bundled: `config/DUAL_CHAIN_TOKEN_LIST.tokenlist.json`. **Hosted:** `https://explorer.d-bis.org/api/config/token-list` (explorer API). `TOKEN_LIST_URL` in code points to this by default. |
| **Feature parity and recommendations** | `docs/04-configuration/metamask/METAMASK_CHAIN138_FEATURE_PARITY_ANALYSIS.md` | Plugin/snap requirements, gaps, and build/integration options. |
| **Oracle and pricing** | `docs/04-configuration/metamask/ORACLE_PRICE_FEED_SETUP.md`, `WETH_ORACLE_QUICK_REFERENCE.md` | Oracle addresses and Oracle Publisher setup. |
| **Token-aggregation REST API** | `smom-dbis-138/services/token-aggregation/docs/REST_API_REFERENCE.md` | Tokens, pools, prices, volume, OHLCV for Chain 138 and ALL Mainnet (discovery without CMC/CoinGecko). |
| **Optional next steps** | `docs/04-configuration/metamask/METAMASK_CHAIN138_FEATURE_PARITY_ANALYSIS.md` §7, `SNAP_IMPLEMENTATION_ROADMAP.md` | Custom Snap roadmap, CoinGecko submission, Consensys outreach. |

## Oracles

- **Chain 138**: ETH/USD at `0x3304b747e565a97ec8ac220b0b6a1f6ffdb837e6` (8 decimals). Keep the Oracle Publisher service running so the feed stays updated.
- **Ethereum Mainnet**: Chainlink ETH/USD at `0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419`.

MetaMask does not read these oracles by default; use `getEthUsdPrice(provider, chainId)` in your dApp to show USD values.

## License

MIT
