/**
 * MetaMask Dual-Chain Provider
 * Connect MetaMask and other Web3 providers to ChainID 138 (DeFi Oracle Meta Mainnet)
 * and Ethereum Mainnet (1). Includes chain configs, token list, and oracle helpers.
 *
 * Usage:
 *   import { addChainsToWallet, switchChain, getEthUsdPrice, getTokensByChain } from './provider'
 *   await addChainsToWallet(window.ethereum)
 *   const price = await getEthUsdPrice(provider, 138)
 */

export {
  CHAINS,
  CHAIN_138,
  CHAIN_MAINNET,
  CHAIN_ALL_MAINNET,
  getChainById,
  getChainByHex,
} from './chains.js'

export {
  ORACLES_CHAIN_138,
  ORACLES_MAINNET,
  ORACLE_ABI,
  getEthUsdPrice,
  getOracleConfig,
} from './oracles.js'

export {
  TOKEN_LIST,
  TOKEN_LIST_URL,
  getTokensByChain,
  getToken,
} from './tokens.js'

export { addChainsToWallet, switchChain, addTokenToWallet, ensureChain } from './wallet.js'
