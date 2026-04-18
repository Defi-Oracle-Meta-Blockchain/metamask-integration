/**
 * Oracle addresses and helpers for Chain 138 and Ethereum Mainnet.
 * Use these to read price feeds so dApps (and optional wallet overlays) can show USD values.
 *
 * Chain 138: MetaMask’s **native** token/fiat column uses a **central price service**, not
 * your RPC or on-chain feeds — custom chains often stay unmapped until third-party listings exist.
 * Use `getEthUsdPrice` / `getAssetUsdPrice` in **your dApp UI**, explorer Snap flows, or
 * token-aggregation APIs for multi-asset USD.
 */

/** Chain 138: ETH/USD reads (prefer keeper-synced mock; legacy proxy often returns zero) */
export const ORACLES_CHAIN_138 = {
  chainId: 138,
  /** Legacy proxy — do not rely on for live reads */
  ethUsdProxy: '0x3304b747e565a97ec8ac220b0b6a1f6ffdb837e6',
  /** Keeper-synced MockPriceFeed (8 decimals); same as `CHAIN138_WETH_MOCK_PRICE_FEED` */
  ethUsdAggregator: '0x3e8725b8De386feF3eFE5678c92eA6aDB41992B2',
  /** Managed aggregator slot (Chainlink-style staleness rules; can lag on Besu) */
  legacyEthUsdAggregator: '0x99b3511a2d315a497c8112c1fdd8d508d4b1e506',
  decimals: 8,
  rpcUrl: 'https://rpc-http-pub.d-bis.org',
}

/**
 * Chain 138 tokens we treat as ~$1 USD for dApp / Snap UX hints (not MetaMask’s built-in column).
 * Includes compliant **cUSDT/cUSDC**, **V2** mints, and official-mirror **USDT/USDC** used in D3 routing.
 */
export const CHAIN138_STABLE_USD_1 = new Set(
  [
    '0x93E66202A11B1772E55407B32B44e5Cd8eda7f22', // cUSDT
    '0xf22258f57794CC8E06237084b353Ab30fFfa640b', // cUSDC
    '0x9FBfab33882Efe0038DAa608185718b772EE5660', // cUSDT V2
    '0x219522c60e83dEe01FC5b0329d6fA8fD84b9D13d', // cUSDC V2
    '0x004b63A7B5b0E06f6bB6adb4a5F9f590BF3182D1', // USDT (official mirror, D3)
    '0x71D6687F38b93CCad569Fa6352c876eea967201b', // USDC (official mirror, D3)
  ].map((a) => a.toLowerCase()),
)

const WETH_VARIANTS = new Set(
  [
    '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2', // WETH9
    '0xf4BB2e28688e89fCcE3c0580D37d36A7672E8A9f', // WETH10
  ].map((a) => a.toLowerCase()),
)

/** Ethereum Mainnet: Chainlink ETH/USD */
export const ORACLES_MAINNET = {
  chainId: 1,
  ethUsdProxy: '0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419',
  decimals: 8,
  rpcUrl: 'https://eth.llamarpc.com',
}

/** Minimal ABI for latestRoundData (Chainlink-compatible) */
export const ORACLE_ABI = [
  'function latestRoundData() external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)',
  'function decimals() external view returns (uint8)',
]

/**
 * Read ETH/USD from a Chainlink-compatible feed contract.
 * @param {import('ethers').Provider} provider
 * @param {string} feedAddress
 */
async function readEthUsdFromFeed(provider, feedAddress) {
  const { ethers } = await import('ethers')
  const contract = new ethers.Contract(feedAddress, ORACLE_ABI, provider)
  const [roundId, answer, , updatedAt] = await contract.latestRoundData()
  const decimals = Number(await contract.decimals())
  const price = Number(answer) / 10 ** decimals
  return {
    price,
    updatedAt: new Date(Number(updatedAt) * 1000),
    decimals,
    roundId: Number(roundId),
    feedAddress,
  }
}

/**
 * Get ETH/USD price for the given chain (138 uses keeper-synced mock first).
 * @param {import('ethers').Provider} provider - ethers v6 JsonRpcProvider or BrowserProvider
 * @param {number} chainId - 138 or 1
 * @returns {Promise<{ price: number, updatedAt: Date, decimals: number, feedAddress?: string } | null>}
 */
export async function getEthUsdPrice(provider, chainId) {
  if (chainId === 1) {
    try {
      return await readEthUsdFromFeed(provider, ORACLES_MAINNET.ethUsdProxy)
    } catch (err) {
      console.error('getEthUsdPrice mainnet error:', err)
      return null
    }
  }

  if (chainId !== 138) return null

  const cfg = ORACLES_CHAIN_138
  const tryFeeds = [cfg.ethUsdAggregator, cfg.legacyEthUsdAggregator, cfg.ethUsdProxy]

  for (const addr of tryFeeds) {
    try {
      const out = await readEthUsdFromFeed(provider, addr)
      if (out.price > 0 && !Number.isNaN(out.price)) {
        return out
      }
    } catch {
      // try next
    }
  }
  return null
}

/**
 * USD hint for a token on Chain 138 (dApp use). Returns null if unknown.
 * Stablecoins (~$1): cUSDT, cUSDC, their V2 mints, and mirror USDT/USDC (D3 routing addresses).
 * WETH9/WETH10: ETH/USD from on-chain feeds.
 * @param {import('ethers').Provider} provider
 * @param {number} chainId
 * @param {string} tokenAddress - ERC-20 (checksummed or not)
 * @returns {Promise<{ usd: number, source: string } | null>}
 */
export async function getAssetUsdPrice(provider, chainId, tokenAddress) {
  if (!tokenAddress || chainId !== 138) return null
  const a = tokenAddress.toLowerCase()
  if (CHAIN138_STABLE_USD_1.has(a)) {
    return { usd: 1, source: 'policy:GRU_USD_stable_1' }
  }
  if (WETH_VARIANTS.has(a)) {
    const eth = await getEthUsdPrice(provider, 138)
    if (!eth) return null
    return { usd: eth.price, source: `eth_usd:${eth.feedAddress ?? 'feed'}` }
  }
  return null
}

/**
 * Get oracle config for a chain (for custom contract usage).
 * @param {number} chainId - 138 or 1
 */
export function getOracleConfig(chainId) {
  if (chainId === 138) return ORACLES_CHAIN_138
  if (chainId === 1) return ORACLES_MAINNET
  return null
}
