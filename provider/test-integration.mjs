#!/usr/bin/env node
/**
 * Provider integration test (Node).
 * Tests chain configs, token list, and exports without window.ethereum.
 * Run: node test-integration.mjs
 */

const assert = (ok, msg) => {
  if (!ok) throw new Error(msg)
}

async function main() {
  console.log('Provider integration test (Node)\n')

  const { CHAINS, CHAIN_138, CHAIN_MAINNET, CHAIN_ALL_MAINNET, getChainById, getChainByHex } = await import('./chains.js')
  const { getTokensByChain, getToken, TOKEN_LIST_URL } = await import('./tokens.js')
  const { addChainsToWallet, switchChain, addTokenToWallet, ensureChain } = await import('./wallet.js')
  const { ORACLES_CHAIN_138, ORACLES_MAINNET, getOracleConfig } = await import('./oracles.js')

  let passed = 0
  let failed = 0

  // Chains
  try {
    assert(Array.isArray(CHAINS) && CHAINS.length >= 3, 'CHAINS has at least 3 entries')
    assert(CHAIN_138 && CHAIN_138.chainIdDecimal === 138, 'CHAIN_138 has chainIdDecimal 138')
    assert(CHAIN_MAINNET && CHAIN_MAINNET.chainIdDecimal === 1, 'CHAIN_MAINNET has chainIdDecimal 1')
    assert(CHAIN_ALL_MAINNET && CHAIN_ALL_MAINNET.chainIdDecimal === 651940, 'CHAIN_ALL_MAINNET has chainIdDecimal 651940')
    assert(getChainById(138) === CHAIN_138, 'getChainById(138) returns CHAIN_138')
    assert(getChainById(1) === CHAIN_MAINNET, 'getChainById(1) returns CHAIN_MAINNET')
    assert(getChainByHex('0x8a') === CHAIN_138, 'getChainByHex(0x8a) returns CHAIN_138')
    console.log('  ✓ Chains (CHAINS, CHAIN_138, CHAIN_MAINNET, CHAIN_ALL_MAINNET, getChainById, getChainByHex)')
    passed++
  } catch (e) {
    console.log('  ✗ Chains:', e.message)
    failed++
  }

  // Tokens
  try {
    const t138 = getTokensByChain(138)
    const t1 = getTokensByChain(1)
    const t651940 = getTokensByChain(651940)
    assert(Array.isArray(t138) && t138.length > 0, 'getTokensByChain(138) returns non-empty array')
    assert(Array.isArray(t1) && t1.length > 0, 'getTokensByChain(1) returns non-empty array')
    assert(Array.isArray(t651940), 'getTokensByChain(651940) returns array')
    assert(typeof TOKEN_LIST_URL === 'string' && TOKEN_LIST_URL.length > 0, 'TOKEN_LIST_URL is set')
    const weth138 = getToken(138, '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2')
    assert(weth138 && weth138.symbol, 'getToken(138, WETH9) returns token with symbol')
    console.log('  ✓ Tokens (getTokensByChain, getToken, TOKEN_LIST_URL)')
    passed++
  } catch (e) {
    console.log('  ✗ Tokens:', e.message)
    failed++
  }

  // Wallet (exports only; no window.ethereum)
  try {
    assert(typeof addChainsToWallet === 'function', 'addChainsToWallet is function')
    assert(typeof switchChain === 'function', 'switchChain is function')
    assert(typeof addTokenToWallet === 'function', 'addTokenToWallet is function')
    assert(typeof ensureChain === 'function', 'ensureChain is function')
    console.log('  ✓ Wallet exports (addChainsToWallet, switchChain, addTokenToWallet, ensureChain)')
    passed++
  } catch (e) {
    console.log('  ✗ Wallet:', e.message)
    failed++
  }

  // Oracles
  try {
    assert(ORACLES_CHAIN_138 && ORACLES_CHAIN_138.ethUsdProxy, 'ORACLES_CHAIN_138 has ethUsdProxy')
    assert(ORACLES_MAINNET && ORACLES_MAINNET.ethUsdProxy, 'ORACLES_MAINNET has ethUsdProxy')
    const cfg138 = getOracleConfig(138)
    const cfg1 = getOracleConfig(1)
    assert(cfg138 && cfg138.ethUsdProxy, 'getOracleConfig(138) has ethUsdProxy')
    assert(cfg1 && cfg1.ethUsdProxy, 'getOracleConfig(1) has ethUsdProxy')
    console.log('  ✓ Oracles (ORACLES_CHAIN_138, ORACLES_MAINNET, getOracleConfig)')
    passed++
  } catch (e) {
    console.log('  ✗ Oracles:', e.message)
    failed++
  }

  console.log('')
  if (failed === 0) {
    console.log(`Result: ${passed} passed, 0 failed`)
    process.exit(0)
  } else {
    console.log(`Result: ${passed} passed, ${failed} failed`)
    process.exit(1)
  }
}

main().catch((err) => {
  console.error(err)
  process.exit(1)
})
