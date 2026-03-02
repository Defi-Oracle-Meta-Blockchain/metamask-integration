/**
 * Wallet helpers for MetaMask and EIP-1193 providers.
 * Add chains (138 + Mainnet), switch chain, add tokens.
 */

import { CHAINS, getChainByHex, getChainById } from './chains.js'
import { getTokensByChain, getToken } from './tokens.js'

/**
 * Add both Chain 138 and Ethereum Mainnet to the wallet (if not already added).
 * @param {import('ethers').Eip1193Provider} ethereum - window.ethereum or other EIP-1193 provider
 * @param {{ chains?: number[] }} options - optional: { chains: [138, 1] } to add only specific chains
 * @returns {Promise<{ added: number[], skipped: number[], errors: { chainId: number, error: Error }[] }>}
 */
export async function addChainsToWallet(ethereum, options = {}) {
  const chainIds = options.chains ?? [138, 1]
  const toAdd = CHAINS.filter((c) => chainIds.includes(c.chainIdDecimal))
  const result = { added: [], skipped: [], errors: [] }

  for (const chain of toAdd) {
    try {
      await ethereum.request({
        method: 'wallet_addEthereumChain',
        params: [{ ...chain }],
      })
      result.added.push(chain.chainIdDecimal)
    } catch (err) {
      if (err.code === 4902) {
        result.added.push(chain.chainIdDecimal)
      } else if (err.code === -32603 && /already exists/i.test(String(err.message))) {
        result.skipped.push(chain.chainIdDecimal)
      } else {
        result.errors.push({ chainId: chain.chainIdDecimal, error: err })
      }
    }
  }

  return result
}

/**
 * Switch the wallet to the given chain. If chain is not added, adds it first (wallet_addEthereumChain).
 * @param {import('ethers').Eip1193Provider} ethereum - window.ethereum
 * @param {number} chainIdDecimal - 138 or 1
 * @returns {Promise<void>}
 */
export async function switchChain(ethereum, chainIdDecimal) {
  const chain = getChainById(chainIdDecimal)
  if (!chain) throw new Error(`Unknown chain: ${chainIdDecimal}`)

  try {
    await ethereum.request({
      method: 'wallet_switchEthereumChain',
      params: [{ chainId: chain.chainId }],
    })
  } catch (err) {
    if (err.code === 4902) {
      await ethereum.request({
        method: 'wallet_addEthereumChain',
        params: [chain],
      })
    } else {
      throw err
    }
  }
}

/**
 * Add a token to the wallet (wallet_watchAsset).
 * @param {import('ethers').Eip1193Provider} ethereum - window.ethereum
 * @param {{ chainId: number, address: string, symbol: string, decimals: number, name?: string }} token - token info (use getToken(chainId, address) for known tokens)
 * @returns {Promise<boolean>} - true if user approved
 */
export async function addTokenToWallet(ethereum, token) {
  const result = await ethereum.request({
    method: 'wallet_watchAsset',
    params: {
      type: 'ERC20',
      options: {
        address: token.address,
        symbol: token.symbol,
        decimals: token.decimals,
        ...(token.name && { name: token.name }),
      },
    },
  })
  return !!result
}

/**
 * Ensure the wallet is on the given chain; if not, switch (and add if needed).
 * @param {import('ethers').Eip1193Provider} ethereum - window.ethereum
 * @param {number} chainIdDecimal - 138 or 1
 * @returns {Promise<boolean>} - true if already on chain or switched successfully
 */
export async function ensureChain(ethereum, chainIdDecimal) {
  const hex = await ethereum.request({ method: 'eth_chainId', params: [] })
  const current = parseInt(hex, 16)
  if (current === chainIdDecimal) return true
  await switchChain(ethereum, chainIdDecimal)
  return true
}

export { getTokensByChain, getToken }
