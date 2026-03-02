# DEX Integration Guide for ChainID 138

Complete guide for integrating DEX (Decentralized Exchange) functionality with MetaMask on ChainID 138.

## Overview

This guide covers DEX integration options for ChainID 138, enabling users to swap tokens directly in MetaMask.

## DEX Options

### Option 1: Partner with Existing DEX Providers

#### Recommended Providers

1. **Uniswap**
   - Largest DEX by volume
   - Well-established infrastructure
   - V3 and V4 support
   - **Contact**: https://uniswap.org

2. **1inch**
   - DEX aggregator
   - Best price routing
   - Supports 100+ DEXs
   - **Contact**: https://1inch.io

3. **0x Protocol**
   - DEX aggregation protocol
   - Open source
   - Developer-friendly
   - **Contact**: https://0x.org

4. **ParaSwap**
   - DEX aggregator
   - Gas optimization
   - Multi-chain support
   - **Contact**: https://paraswap.io

#### Integration Steps

1. **Contact DEX Provider**:
   - Request ChainID 138 integration
   - Provide network information
   - Discuss liquidity requirements

2. **Liquidity Requirements**:
   - Minimum liquidity per pair
   - Liquidity distribution
   - Liquidity incentives

3. **Integration Process**:
   - Deploy DEX contracts on ChainID 138
   - Configure DEX endpoints
   - Add liquidity to pools
   - Test swap functionality
   - Launch DEX

### Option 2: Deploy Custom DEX

#### Architecture

```
┌─────────────┐
│   Users     │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  DEX Router │
└──────┬──────┘
       │
       ├──► Pool 1 (cUSDT/cUSDC)
       ├──► Pool 2 (cUSDT/WETH)
       ├──► Pool 3 (cUSDC/WETH)
       └──► Pool N (...)
```

#### Components

1. **DEX Router Contract**
   - Routes swaps to best pool
   - Handles multi-hop swaps
   - Manages swap fees

2. **Liquidity Pools**
   - AMM (Automated Market Maker) pools
   - Constant product formula (x * y = k)
   - Liquidity provider tokens

3. **Factory Contract**
   - Creates new pools
   - Manages pool registry
   - Sets pool parameters

#### Implementation Steps

1. **Deploy DEX Contracts**:
   ```bash
   # Deploy Factory
   forge script script/dex/DeployFactory.s.sol --rpc-url $RPC_URL_138
   
   # Deploy Router
   forge script script/dex/DeployRouter.s.sol --rpc-url $RPC_URL_138
   
   # Create Initial Pools
   forge script script/dex/CreatePools.s.sol --rpc-url $RPC_URL_138
   ```

2. **Add Initial Liquidity**:
   - Add liquidity to cUSDT/cUSDC pool
   - Add liquidity to cUSDT/WETH pool
   - Add liquidity to cUSDC/WETH pool

3. **Configure DEX**:
   - Set swap fees
   - Configure pool parameters
   - Set up monitoring

4. **Security Audit**:
   - Conduct security audit
   - Fix identified issues
   - Deploy audited contracts

### Option 3: Use DEX Aggregator

#### Aggregators

1. **1inch Aggregator**
   - Best price routing
   - Gas optimization
   - Multi-DEX support
   - **Integration**: https://docs.1inch.io

2. **0x API**
   - DEX aggregation API
   - Price discovery
   - Order routing
   - **Integration**: https://0x.org/docs/api

3. **ParaSwap API**
   - DEX aggregation
   - Best route finding
   - Gas optimization
   - **Integration**: https://developers.paraswap.network

## MetaMask Swaps Integration

### Requirements

1. **DEX Integration**:
   - DEX deployed and operational
   - Sufficient liquidity
   - Security audit completed

2. **Token Support**:
   - Supported tokens listed
   - Token metadata complete
   - Token logos available

3. **Liquidity**:
   - Minimum liquidity per pair
   - Liquidity distribution
   - Liquidity incentives

4. **Consensys Approval**:
   - Submit DEX for MetaMask approval
   - Provide security documentation
   - Complete integration review

### Integration Process

1. **Phase 1: DEX Setup** (Month 1-2)
   - Deploy DEX contracts
   - Add initial liquidity
   - Test swap functionality

2. **Phase 2: Security Audit** (Month 2-3)
   - Conduct security audit
   - Fix identified issues
   - Deploy audited contracts

3. **Phase 3: MetaMask Integration** (Month 3-6)
   - Submit to MetaMask
   - Complete integration review
   - Test MetaMask integration
   - Launch swaps

## DEX Configuration

### Supported Token Pairs

- **cUSDT/cUSDC**: Stablecoin pair
- **cUSDT/WETH**: Stablecoin/ETH pair
- **cUSDC/WETH**: Stablecoin/ETH pair
- **WETH/LINK**: ETH/Oracle pair

### Swap Fees

- **Trading Fee**: 0.3% (standard) or 0.05% (stablecoin pairs)
- **Protocol Fee**: 0.05% (to protocol treasury)
- **LP Fee**: 0.25% (to liquidity providers)

### Liquidity Requirements

- **Minimum**: $10,000 per pair
- **Recommended**: $100,000+ per pair
- **Optimal**: $1,000,000+ per pair

## Testing

### Test Scenarios

1. **Basic Swaps**:
   - Swap cUSDT for cUSDC
   - Swap cUSDC for WETH
   - Swap WETH for cUSDT
   - Verify swap amounts

2. **Edge Cases**:
   - Swap minimum amount
   - Swap maximum amount
   - Swap with high slippage
   - Swap with low liquidity

3. **Security**:
   - Test price manipulation
   - Test flash loan attacks
   - Test reentrancy
   - Test front-running

## Monitoring

### Metrics to Monitor

- Swap volume
- Swap success rate
- Liquidity levels
- Price impact
- Gas costs
- Security events

### Alerts

- Low liquidity warnings
- High slippage alerts
- Failed swaps
- Security incidents

## Documentation

### User Documentation

- How to swap tokens
- Swap fees and limits
- Slippage tolerance
- Troubleshooting guide

### Developer Documentation

- DEX API documentation
- Integration examples
- SDK documentation
- Contract addresses

## Support

### User Support

- Swap transaction issues
- Swap fee questions
- Slippage questions
- Troubleshooting

### Developer Support

- Integration help
- API questions
- Contract questions
- Testing support

---

**Last Updated**: 2026-01-26
