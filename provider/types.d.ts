/**
 * Types for MetaMask dual-chain provider (Chain 138 + Ethereum Mainnet).
 */

export interface ChainParams {
  chainId: string
  chainIdDecimal: number
  chainName: string
  nativeCurrency: { name: string; symbol: string; decimals: number }
  rpcUrls: string[]
  blockExplorerUrls: string[]
  iconUrls?: string[]
}

export interface TokenInfo {
  chainId: number
  address: string
  name: string
  symbol: string
  decimals: number
  logoURI?: string
  tags?: string[]
}

export interface OraclePriceResult {
  price: number
  updatedAt: Date
  decimals: number
  roundId?: number
  /** Chain 138: which feed answered (mock, legacy aggregator, or proxy) */
  feedAddress?: string
}

export interface AssetUsdHint {
  usd: number
  source: string
}
