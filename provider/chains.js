/**
 * Multi-chain network params for MetaMask and Web3 providers.
 * 13 chains: 138, 1, 651940, 25, 56, 100, 137, 10, 42161, 8453, 43114, 42220, 1111.
 * Use with wallet_addEthereumChain and wallet_switchEthereumChain.
 *
 * @typedef {Object} ChainParams
 * @property {string} chainId
 * @property {number} chainIdDecimal
 * @property {string} chainName
 * @property {{ name: string, symbol: string, decimals: number }} nativeCurrency
 * @property {string[]} rpcUrls
 * @property {string[]} blockExplorerUrls
 * @property {string[]} [iconUrls]
 */

/** @type {ChainParams[]} */
export const CHAINS = [
  {
    chainId: '0x8a',
    chainIdDecimal: 138,
    chainName: 'DeFi Oracle Meta Mainnet',
    nativeCurrency: { name: 'Ether', symbol: 'ETH', decimals: 18 },
    rpcUrls: [
      'https://rpc-http-pub.d-bis.org',
      'https://rpc.d-bis.org',
      'https://rpc2.d-bis.org',
      'https://rpc.defi-oracle.io',
    ],
    blockExplorerUrls: ['https://explorer.d-bis.org', 'https://blockscout.defi-oracle.io'],
    iconUrls: [
      'https://raw.githubusercontent.com/ethereum/ethereum.org/main/static/images/eth-diamond-black.png',
    ],
  },
  {
    chainId: '0x1',
    chainIdDecimal: 1,
    chainName: 'Ethereum Mainnet',
    nativeCurrency: { name: 'Ether', symbol: 'ETH', decimals: 18 },
    rpcUrls: [
      'https://eth.llamarpc.com',
      'https://rpc.ankr.com/eth',
      'https://ethereum.publicnode.com',
      'https://1rpc.io/eth',
    ],
    blockExplorerUrls: ['https://etherscan.io'],
    iconUrls: [
      'https://raw.githubusercontent.com/ethereum/ethereum.org/main/static/images/eth-diamond-black.png',
    ],
  },
  {
    chainId: '0x9f2c4',
    chainIdDecimal: 651940,
    chainName: 'ALL Mainnet',
    nativeCurrency: { name: 'Ether', symbol: 'ETH', decimals: 18 },
    rpcUrls: ['https://mainnet-rpc.alltra.global'],
    blockExplorerUrls: ['https://alltra.global'],
    iconUrls: [
      'https://raw.githubusercontent.com/ethereum/ethereum.org/main/static/images/eth-diamond-black.png',
    ],
  },
  {
    chainId: '0x19',
    chainIdDecimal: 25,
    chainName: 'Cronos Mainnet',
    nativeCurrency: { name: 'CRO', symbol: 'CRO', decimals: 18 },
    rpcUrls: ['https://evm.cronos.org', 'https://cronos-rpc.publicnode.com'],
    blockExplorerUrls: ['https://cronos.org/explorer'],
    iconUrls: ['https://raw.githubusercontent.com/ethereum/ethereum.org/main/static/images/eth-diamond-black.png'],
  },
  {
    chainId: '0x38',
    chainIdDecimal: 56,
    chainName: 'BNB Smart Chain',
    nativeCurrency: { name: 'BNB', symbol: 'BNB', decimals: 18 },
    rpcUrls: ['https://bsc-dataseed.binance.org', 'https://bsc-dataseed1.defibit.io'],
    blockExplorerUrls: ['https://bscscan.com'],
    iconUrls: ['https://raw.githubusercontent.com/ethereum/ethereum.org/main/static/images/eth-diamond-black.png'],
  },
  {
    chainId: '0x64',
    chainIdDecimal: 100,
    chainName: 'Gnosis Chain',
    nativeCurrency: { name: 'xDAI', symbol: 'xDAI', decimals: 18 },
    rpcUrls: ['https://rpc.gnosischain.com', 'https://gnosis-rpc.publicnode.com'],
    blockExplorerUrls: ['https://gnosisscan.io'],
    iconUrls: ['https://raw.githubusercontent.com/ethereum/ethereum.org/main/static/images/eth-diamond-black.png'],
  },
  {
    chainId: '0x89',
    chainIdDecimal: 137,
    chainName: 'Polygon',
    nativeCurrency: { name: 'MATIC', symbol: 'MATIC', decimals: 18 },
    rpcUrls: ['https://polygon-rpc.com', 'https://polygon.llamarpc.com'],
    blockExplorerUrls: ['https://polygonscan.com'],
    iconUrls: ['https://raw.githubusercontent.com/ethereum/ethereum.org/main/static/images/eth-diamond-black.png'],
  },
  {
    chainId: '0xa',
    chainIdDecimal: 10,
    chainName: 'Optimism',
    nativeCurrency: { name: 'Ether', symbol: 'ETH', decimals: 18 },
    rpcUrls: ['https://mainnet.optimism.io', 'https://optimism.llamarpc.com'],
    blockExplorerUrls: ['https://optimistic.etherscan.io'],
    iconUrls: ['https://raw.githubusercontent.com/ethereum/ethereum.org/main/static/images/eth-diamond-black.png'],
  },
  {
    chainId: '0xa4b1',
    chainIdDecimal: 42161,
    chainName: 'Arbitrum One',
    nativeCurrency: { name: 'Ether', symbol: 'ETH', decimals: 18 },
    rpcUrls: ['https://arb1.arbitrum.io/rpc', 'https://arbitrum.llamarpc.com'],
    blockExplorerUrls: ['https://arbiscan.io'],
    iconUrls: ['https://raw.githubusercontent.com/ethereum/ethereum.org/main/static/images/eth-diamond-black.png'],
  },
  {
    chainId: '0x2105',
    chainIdDecimal: 8453,
    chainName: 'Base',
    nativeCurrency: { name: 'Ether', symbol: 'ETH', decimals: 18 },
    rpcUrls: ['https://mainnet.base.org', 'https://base.llamarpc.com'],
    blockExplorerUrls: ['https://basescan.org'],
    iconUrls: ['https://raw.githubusercontent.com/ethereum/ethereum.org/main/static/images/eth-diamond-black.png'],
  },
  {
    chainId: '0xa86a',
    chainIdDecimal: 43114,
    chainName: 'Avalanche C-Chain',
    nativeCurrency: { name: 'AVAX', symbol: 'AVAX', decimals: 18 },
    rpcUrls: ['https://api.avax.network/ext/bc/C/rpc'],
    blockExplorerUrls: ['https://snowtrace.io'],
    iconUrls: ['https://raw.githubusercontent.com/ethereum/ethereum.org/main/static/images/eth-diamond-black.png'],
  },
  {
    chainId: '0xa4ec',
    chainIdDecimal: 42220,
    chainName: 'Celo',
    nativeCurrency: { name: 'CELO', symbol: 'CELO', decimals: 18 },
    rpcUrls: ['https://forno.celo.org'],
    blockExplorerUrls: ['https://celoscan.io'],
    iconUrls: ['https://raw.githubusercontent.com/ethereum/ethereum.org/main/static/images/eth-diamond-black.png'],
  },
  {
    chainId: '0x457',
    chainIdDecimal: 1111,
    chainName: 'Wemix',
    nativeCurrency: { name: 'WEMIX', symbol: 'WEMIX', decimals: 18 },
    rpcUrls: ['https://api.wemix.com'],
    blockExplorerUrls: ['https://scan.wemix.com'],
    iconUrls: ['https://raw.githubusercontent.com/ethereum/ethereum.org/main/static/images/eth-diamond-black.png'],
  },
]

/** Chain 138 only (for wallet_addEthereumChain single chain) */
export const CHAIN_138 = CHAINS[0]

/** Ethereum Mainnet only */
export const CHAIN_MAINNET = CHAINS[1]

/** ALL Mainnet only (651940) */
export const CHAIN_ALL_MAINNET = CHAINS[2]

/**
 * @param {number} chainIdDecimal - 138, 1, 651940, 25, 56, 100, 137, 10, 42161, 8453, 43114, 42220, 1111
 * @returns {ChainParams | undefined}
 */
export function getChainById(chainIdDecimal) {
  return CHAINS.find((c) => c.chainIdDecimal === chainIdDecimal)
}

/**
 * @param {string} chainIdHex - e.g. '0x8a', '0x1', '0x9f2c4', '0x19', etc.
 * @returns {ChainParams | undefined}
 */
export function getChainByHex(chainIdHex) {
  return CHAINS.find((c) => c.chainId === chainIdHex)
}
