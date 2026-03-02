# On-Ramp Integration Guide for ChainID 138

Complete guide for integrating on-ramp (buy/sell) functionality with MetaMask on ChainID 138.

## Overview

This guide covers on-ramp integration options for ChainID 138, enabling users to buy and sell tokens with fiat currency directly in MetaMask.

## On-Ramp Providers

### Recommended Providers

1. **MoonPay**
   - Leading on-ramp provider
   - Supports 100+ countries
   - Multiple payment methods
   - **Contact**: https://www.moonpay.com/business
   - **Integration**: https://developers.moonpay.com

2. **Ramp Network**
   - European-focused
   - Fast KYC process
   - Competitive fees
   - **Contact**: https://ramp.network
   - **Integration**: https://docs.ramp.network

3. **Transak**
   - Global coverage
   - Multiple payment methods
   - Developer-friendly
   - **Contact**: https://transak.com
   - **Integration**: https://docs.transak.com

4. **Wyre**
   - US-focused
   - Bank transfers
   - ACH support
   - **Contact**: https://www.sendwyre.com
   - **Integration**: https://docs.sendwyre.com

5. **Banxa**
   - Global coverage
   - Multiple payment methods
   - Fast processing
   - **Contact**: https://banxa.com
   - **Integration**: https://docs.banxa.com

## Integration Process

### Step 1: Choose Provider

Considerations:
- **Geographic Coverage**: Which countries are supported?
- **Payment Methods**: Credit card, bank transfer, etc.
- **Fees**: Transaction fees and limits
- **KYC Requirements**: KYC process and requirements
- **Integration Complexity**: Ease of integration
- **Support**: Developer and user support

### Step 2: Partner with Provider

1. **Contact Provider**:
   - Request ChainID 138 integration
   - Provide network information
   - Discuss partnership terms

2. **Requirements**:
   - Network information
   - Token information
   - Compliance documentation
   - Business information

3. **Agreement**:
   - Partnership terms
   - Fee structure
   - Integration timeline
   - Support agreement

### Step 3: Technical Integration

#### MoonPay Integration Example

```javascript
// MoonPay Widget Integration
import { MoonPayBuyWidget } from '@moonpay/moonpay-js';

const moonPay = new MoonPayBuyWidget({
  apiKey: 'YOUR_API_KEY',
  environment: 'production',
  variant: 'overlay',
  baseCurrencyCode: 'usd',
  baseCurrencyAmount: '100',
  defaultCurrencyCode: 'eth',
  walletAddress: userAddress,
  walletAddresses: {
    eth: userAddress,
    // Add ChainID 138 address
  },
  onClose: () => {
    console.log('Widget closed');
  },
  onComplete: (data) => {
    console.log('Transaction complete', data);
  },
});

moonPay.show();
```

#### Ramp Integration Example

```javascript
// Ramp Widget Integration
import { RampInstant } from '@ramp-network/ramp-instant';

const ramp = new RampInstant({
  hostAppName: 'Your App',
  hostLogoUrl: 'https://your-app.com/logo.png',
  variant: 'auto',
  defaultAsset: 'ETH_138', // ChainID 138 ETH
  userAddress: userAddress,
  onClose: () => {
    console.log('Widget closed');
  },
  onPurchaseCreated: (purchase) => {
    console.log('Purchase created', purchase);
  },
});
```

### Step 4: Configure Network

1. **Add ChainID 138 to Provider**:
   - Provide network configuration
   - Configure RPC endpoints
   - Set up token support

2. **Token Configuration**:
   - Add supported tokens
   - Configure token metadata
   - Set up token logos

3. **Testing**:
   - Test buy flow
   - Test sell flow
   - Test error handling

## Supported Tokens

### Buy (Fiat → Crypto)

- **ETH**: Native currency
- **cUSDT**: Compliant Tether USD
- **cUSDC**: Compliant USD Coin
- **WETH**: Wrapped Ether
- **LINK**: Chainlink Token

### Sell (Crypto → Fiat)

- **ETH**: Native currency
- **cUSDT**: Compliant Tether USD
- **cUSDC**: Compliant USD Coin

## Payment Methods

### Supported Methods

1. **Credit/Debit Cards**:
   - Visa, Mastercard, Amex
   - Instant processing
   - Higher fees

2. **Bank Transfers**:
   - ACH (US)
   - SEPA (Europe)
   - Lower fees
   - Slower processing

3. **Apple Pay / Google Pay**:
   - Mobile payments
   - Fast processing
   - Higher fees

4. **Crypto Payments**:
   - Pay with other cryptocurrencies
   - Instant processing
   - Lower fees

## Fees and Limits

### Typical Fees

- **Credit Card**: 3-5%
- **Bank Transfer**: 1-2%
- **Apple Pay / Google Pay**: 3-5%
- **Crypto Payment**: 0.5-1%

### Typical Limits

- **Minimum**: $10-50
- **Maximum (Daily)**: $1,000-10,000
- **Maximum (Monthly)**: $10,000-100,000
- **KYC Required**: Varies by amount

## KYC/AML Requirements

### KYC Levels

1. **Level 1 (No KYC)**:
   - Small amounts only
   - Limited features
   - Basic verification

2. **Level 2 (Basic KYC)**:
   - Email verification
   - Phone verification
   - ID verification

3. **Level 3 (Full KYC)**:
   - Full identity verification
   - Address verification
   - Enhanced due diligence

### Compliance

- **KYC**: Know Your Customer
- **AML**: Anti-Money Laundering
- **Sanctions**: Sanctions screening
- **Regulatory**: Regulatory compliance

## MetaMask Integration

### Requirements

1. **On-Ramp Provider Partnership**:
   - Partner with on-ramp provider
   - Complete integration
   - Test functionality

2. **Consensys Approval**:
   - Submit on-ramp for MetaMask approval
   - Provide compliance documentation
   - Complete integration review

3. **Compliance**:
   - KYC/AML compliance
   - Regulatory compliance
   - Security compliance

### Integration Process

1. **Phase 1: Provider Integration** (Month 1-2)
   - Partner with provider
   - Complete technical integration
   - Test buy/sell flows

2. **Phase 2: Compliance** (Month 2-3)
   - Complete KYC/AML setup
   - Regulatory compliance
   - Security review

3. **Phase 3: MetaMask Integration** (Month 3-6)
   - Submit to MetaMask
   - Complete integration review
   - Test MetaMask integration
   - Launch on-ramp

## Testing

### Test Scenarios

1. **Buy Flow**:
   - Buy ETH with credit card
   - Buy cUSDT with bank transfer
   - Verify tokens received
   - Test error handling

2. **Sell Flow**:
   - Sell ETH for fiat
   - Sell cUSDT for fiat
   - Verify fiat received
   - Test error handling

3. **Edge Cases**:
   - Minimum amount
   - Maximum amount
   - Failed payments
   - Refunds

## Monitoring

### Metrics to Monitor

- Buy/sell volume
- Success rate
- Average transaction time
- Fee collection
- User complaints
- Security events

### Alerts

- Failed transactions
- High failure rate
- Security incidents
- Compliance issues

## Documentation

### User Documentation

- How to buy tokens
- How to sell tokens
- Payment methods
- Fees and limits
- KYC process
- Troubleshooting guide

### Developer Documentation

- On-ramp API documentation
- Integration examples
- SDK documentation
- Webhook documentation

## Support

### User Support

- Buy/sell transaction issues
- Payment method questions
- KYC questions
- Troubleshooting

### Developer Support

- Integration help
- API questions
- Webhook questions
- Testing support

---

**Last Updated**: 2026-01-26
