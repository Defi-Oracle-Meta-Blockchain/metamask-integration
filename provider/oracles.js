/**
 * Oracle addresses and helpers for Chain 138 and Ethereum Mainnet.
 * Use these to read price feeds so MetaMask and dApps can display USD values.
 */

/** Chain 138: ETH/USD proxy and aggregator */
export const ORACLES_CHAIN_138 = {
  chainId: 138,
  ethUsdProxy: '0x3304b747e565a97ec8ac220b0b6a1f6ffdb837e6',
  aggregator: '0x99b3511a2d315a497c8112c1fdd8d508d4b1e506',
  decimals: 8,
  rpcUrl: 'https://rpc-http-pub.d-bis.org',
}

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
 * Get ETH/USD price from the appropriate oracle for the given chain.
 * @param {import('ethers').Provider} provider - ethers v6 JsonRpcProvider or BrowserProvider
 * @param {number} chainId - 138 or 1
 * @returns {Promise<{ price: number, updatedAt: Date, decimals: number } | null>}
 */
export async function getEthUsdPrice(provider, chainId) {
  const oracleConfig = chainId === 138 ? ORACLES_CHAIN_138 : chainId === 1 ? ORACLES_MAINNET : null
  if (!oracleConfig) return null

  try {
    const { ethers } = await import('ethers')
    const contract = new ethers.Contract(oracleConfig.ethUsdProxy, ORACLE_ABI, provider)
    const [roundId, answer, startedAt, updatedAt] = await contract.latestRoundData()
    const decimals = Number(await contract.decimals())
    const price = Number(answer) / Math.pow(10, decimals)
    return {
      price,
      updatedAt: new Date(Number(updatedAt) * 1000),
      decimals,
      roundId: Number(roundId),
    }
  } catch (err) {
    console.error('getEthUsdPrice error:', err)
    return null
  }
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
