/**
 * Multi-chain token list (Chain 138 + Ethereum Mainnet + ALL Mainnet).
 * Use with wallet_watchAsset and for displaying tokens in dApps.
 */

/** Inline token list for Chain 138, Mainnet, and ALL Mainnet. Matches DUAL_CHAIN_TOKEN_LIST.tokenlist.json */
export const TOKEN_LIST = [
  // Chain 138
  { chainId: 138, address: '0x3304b747e565a97ec8ac220b0b6a1f6ffdb837e6', name: 'ETH/USD Price Feed', symbol: 'ETH-USD', decimals: 8, tags: ['oracle', 'price-feed'] },
  { chainId: 138, address: '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2', name: 'Wrapped Ether', symbol: 'WETH', decimals: 18, tags: ['defi', 'wrapped'] },
  { chainId: 138, address: '0xf4BB2e28688e89fCcE3c0580D37d36A7672E8A9f', name: 'Wrapped Ether v10', symbol: 'WETH', decimals: 18, tags: ['defi', 'wrapped'] },
  { chainId: 138, address: '0x93E66202A11B1772E55407B32B44e5Cd8eda7f22', name: 'Compliant Tether USD', symbol: 'cUSDT', decimals: 6, tags: ['stablecoin', 'defi', 'compliant', 'fiat', 'cash', 'gru'], extensions: { category: 'tokenized-fiat', instrument: 'emoney-or-fiat-backed-stablecoin', currency: 'USD', settlement: 'fiat', cashLike: true, backing: 'cash,cash-equivalents', gruVersion: 'v1', gruFamily: 'cUSDT', walletClass: 'cash-like-token' } },
  { chainId: 138, address: '0xf22258f57794CC8E06237084b353Ab30fFfa640b', name: 'Compliant USD Coin', symbol: 'cUSDC', decimals: 6, tags: ['stablecoin', 'defi', 'compliant', 'fiat', 'cash', 'gru'], extensions: { category: 'tokenized-fiat', instrument: 'emoney-or-fiat-backed-stablecoin', currency: 'USD', settlement: 'fiat', cashLike: true, backing: 'cash,cash-equivalents', gruVersion: 'v1', gruFamily: 'cUSDC', walletClass: 'cash-like-token' } },
  // Ethereum Mainnet
  { chainId: 1, address: '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2', name: 'Wrapped Ether', symbol: 'WETH', decimals: 18, tags: ['defi', 'wrapped'] },
  { chainId: 1, address: '0xdAC17F958D2ee523a2206206994597C13D831ec7', name: 'Tether USD', symbol: 'USDT', decimals: 6, tags: ['stablecoin', 'defi', 'fiat', 'cash'], extensions: { category: 'tokenized-fiat', instrument: 'fiat-backed-stablecoin', currency: 'USD', settlement: 'fiat', cashLike: true, backing: 'cash,cash-equivalents', walletClass: 'cash-like-token' } },
  { chainId: 1, address: '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48', name: 'USD Coin', symbol: 'USDC', decimals: 6, tags: ['stablecoin', 'defi', 'fiat', 'cash'], extensions: { category: 'tokenized-fiat', instrument: 'fiat-backed-stablecoin', currency: 'USD', settlement: 'fiat', cashLike: true, backing: 'cash,cash-equivalents', walletClass: 'cash-like-token' } },
  { chainId: 1, address: '0x6B175474E89094C44Da98b954EedeAC495271d0F', name: 'Dai Stablecoin', symbol: 'DAI', decimals: 18, tags: ['stablecoin', 'defi'], extensions: { category: 'stablecoin', instrument: 'crypto-collateralized-stablecoin', currency: 'USD', settlement: 'crypto-native', cashLike: false, backing: 'crypto-collateral', walletClass: 'stablecoin-token' } },
  { chainId: 1, address: '0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419', name: 'ETH/USD Price Feed', symbol: 'ETH-USD', decimals: 8, tags: ['oracle', 'price-feed'] },
  // ALL Mainnet (651940)
  { chainId: 651940, address: '0xa95EeD79f84E6A0151eaEb9d441F9Ffd50e8e881', name: 'USD Coin', symbol: 'USDC', decimals: 6, tags: ['stablecoin', 'defi', 'fiat', 'cash', 'compliant', 'gru'], extensions: { category: 'tokenized-fiat', instrument: 'emoney-or-fiat-backed-stablecoin', currency: 'USD', settlement: 'fiat', cashLike: true, backing: 'cash,cash-equivalents', gruVersion: 'v1', gruFamily: 'cUSDC', walletClass: 'cash-like-token', bridge: 'AlltraAdapter:cUSDC->USDC' } },
]

/**
 * @param {number} chainId - 138, 1, or 651940
 * @returns {Array<{ chainId: number, address: string, name: string, symbol: string, decimals: number, tags?: string[] }>}
 */
export function getTokensByChain(chainId) {
  return TOKEN_LIST.filter((t) => t.chainId === chainId)
}

/**
 * @param {number} chainId
 * @param {string} address - token contract address (checksummed or lowercase)
 * @returns {typeof TOKEN_LIST[0] | undefined}
 */
export function getToken(chainId, address) {
  const addr = address.toLowerCase()
  return TOKEN_LIST.find((t) => t.chainId === chainId && t.address.toLowerCase() === addr)
}

/**
 * URL to the combined token list JSON (hosted by the explorer API).
 * Override in your app if you host the list elsewhere.
 */
export const TOKEN_LIST_URL = 'https://explorer.d-bis.org/api/config/token-list'
