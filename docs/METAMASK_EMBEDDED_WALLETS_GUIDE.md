# MetaMask Embedded Wallets Integration Guide

**Date**: 2026-01-26  
**Network**: ChainID 138 (DeFi Oracle Meta Mainnet)  
**Reference**: [MetaMask Embedded Wallets Documentation](https://docs.metamask.io/embedded-wallets/dashboard/chains-and-networks/)

---

## Overview

MetaMask Embedded Wallets (powered by Web3Auth) allows developers to embed wallet functionality directly into their dApps without requiring users to install the MetaMask extension. This guide covers integration for ChainID 138.

---

## Key Differences: Embedded Wallets vs Extension

| Feature | MetaMask Extension | Embedded Wallets |
|---------|-------------------|------------------|
| **Installation** | Browser extension required | No installation needed |
| **User Experience** | External wallet | Embedded in dApp |
| **Configuration** | Manual network addition | Dashboard-based configuration |
| **Authentication** | Extension-based | Social/Email/Phone login |
| **Use Case** | Power users | Mass adoption |

---

## Dashboard Configuration

### Step 1: Access MetaMask Embedded Wallets Dashboard

1. Go to [MetaMask Developer Dashboard](https://dashboard.metamask.io)
2. Create a new project or select existing project
3. Navigate to **Configuration → Chains and Networks**

### Step 2: Add ChainID 138 as Custom Network

According to the [MetaMask documentation](https://docs.metamask.io/embedded-wallets/dashboard/chains-and-networks/#adding-custom-networks), add the following:

#### Required Fields:

- **Chain ID**: `138` (or `0x8a` in hex)
- **Currency Symbol**: `ETH`
- **Block Explorer URL**: `https://explorer.d-bis.org`
- **Namespace**: `eip155` (for EVM-compatible chains)
- **RPC URL**: `https://rpc.d-bis.org` (or `https://rpc2.d-bis.org`)

#### Network Configuration:

```json
{
  "chainId": 138,
  "chainName": "DeFi Oracle Meta Mainnet",
  "currencySymbol": "ETH",
  "blockExplorerUrl": "https://explorer.d-bis.org",
  "namespace": "eip155",
  "rpcUrl": "https://rpc.d-bis.org"
}
```

### Step 3: Configure Network Settings

1. **Enable Network**: Toggle ChainID 138 to enabled
2. **Set as Default** (optional): Make ChainID 138 the default network
3. **Testnet/Mainnet**: Mark as Mainnet
4. **Save Configuration**: Click "Save & Publish"

---

## Customization Configuration

### Branding Setup

Navigate to **Configuration → Customization → Branding**:

#### Brand Logo
- **Upload Logo**: Upload ChainID 138 network logo
- **Recommended**: PNG format, 512x512px
- **Use as Loader**: Enable to show logo during loading

#### Application Name
- **Name**: "DeFi Oracle Meta Mainnet" or "ChainID 138"
- **Used in**: Email templates, system communications

#### Terms and Privacy
- **Terms URL**: Link to terms of service
- **Privacy Policy URL**: Link to privacy policy

#### Default Language
- **Language**: English (or preferred language)

### Theme Configuration

Navigate to **Configuration → Customization → Theme and Colors**:

#### Mode Selection
- **Light Mode**: Light theme
- **Dark Mode**: Dark theme
- **Auto Mode**: Adapts to user's system preference (recommended)

#### Color Scheme
- **Primary Color**: Network brand color (e.g., `#667eea`)
- **On Primary Color**: Text color on primary background (e.g., `#ffffff`)

### Login Modal Configuration

Navigate to **Configuration → Customization → Login Modal**:

#### Design Options
- **Modal Appearance**: 
  - **Embedded Widget**: Login UI embedded in page
  - **Modal Widget**: Pop-up modal (recommended)
- **Logo Alignment**: Center or Left
- **Border Radius**: Small, Medium, or Large
- **Border Radius Type**: Pill, Rounded, or Square

#### Authentication Order
- **Arrange Login Methods**: Drag and drop to reorder
  - Social logins (Google, Twitter, etc.)
  - Email/Phone
  - External wallets (MetaMask extension, WalletConnect)

#### External Wallets
- **Show Installed Wallets**: Enable to detect MetaMask extension
- **Number of Wallets**: Configure how many to display

---

## SDK Integration

### React Integration

```typescript
import { Web3Auth } from '@web3auth/modal';
import { CHAIN_NAMESPACES } from '@web3auth/base';

const web3auth = new Web3Auth({
  clientId: 'YOUR_CLIENT_ID', // From dashboard
  chainConfig: {
    chainNamespace: CHAIN_NAMESPACES.EIP155,
    chainId: '0x8a', // 138 in hex
    rpcTarget: 'https://rpc.d-bis.org',
    displayName: 'DeFi Oracle Meta Mainnet',
    blockExplorerUrl: 'https://explorer.d-bis.org',
    ticker: 'ETH',
    tickerName: 'Ether',
  },
});

// Initialize
await web3auth.init();

// Connect
await web3auth.connect();
```

### Vue Integration

```typescript
import { Web3Auth } from '@web3auth/modal';
import { CHAIN_NAMESPACES } from '@web3auth/base';

export default {
  data() {
    return {
      web3auth: null,
      provider: null,
    };
  },
  async mounted() {
    this.web3auth = new Web3Auth({
      clientId: 'YOUR_CLIENT_ID',
      chainConfig: {
        chainNamespace: CHAIN_NAMESPACES.EIP155,
        chainId: '0x8a',
        rpcTarget: 'https://rpc.d-bis.org',
        displayName: 'DeFi Oracle Meta Mainnet',
        blockExplorerUrl: 'https://explorer.d-bis.org',
        ticker: 'ETH',
        tickerName: 'Ether',
      },
    });
    
    await this.web3auth.init();
  },
  methods: {
    async connect() {
      this.provider = await this.web3auth.connect();
    },
  },
};
```

### JavaScript Integration

```javascript
import { Web3Auth } from '@web3auth/modal';
import { CHAIN_NAMESPACES } from '@web3auth/base';

const web3auth = new Web3Auth({
  clientId: 'YOUR_CLIENT_ID',
  chainConfig: {
    chainNamespace: CHAIN_NAMESPACES.EIP155,
    chainId: '0x8a',
    rpcTarget: 'https://rpc.d-bis.org',
    displayName: 'DeFi Oracle Meta Mainnet',
    blockExplorerUrl: 'https://explorer.d-bis.org',
    ticker: 'ETH',
    tickerName: 'Ether',
  },
});

await web3auth.init();
const provider = await web3auth.connect();
```

---

## Token Configuration

### Adding Tokens to Embedded Wallets

Tokens are automatically detected from the token list configured in the dashboard. Ensure your token list includes:

1. **Token Address**: Contract address on ChainID 138
2. **Token Symbol**: Display symbol (e.g., cUSDT, cUSDC)
3. **Token Name**: Full name (e.g., "Compliant Tether USD")
4. **Decimals**: Token decimals (6 for cUSDT/cUSDC, 18 for WETH)
5. **Logo URL**: Accessible logo URL

### Token List Configuration

The token list should be hosted and accessible. See [Token List Hosting Guide](./METAMASK_TOKEN_LIST_HOSTING.md) for details.

---

## Benefits of Embedded Wallets

### For Developers

- ✅ **No SDK Changes**: Network config via dashboard
- ✅ **Instant Updates**: Changes take effect immediately
- ✅ **Environment-Specific**: Different configs for dev/prod
- ✅ **Testnet Support**: Easy switching between networks

### For Users

- ✅ **No Extension Required**: Works in any browser
- ✅ **Social Login**: Login with Google, Twitter, etc.
- ✅ **Email/Phone Login**: Traditional authentication
- ✅ **Seamless Experience**: Embedded in dApp

---

## Integration Checklist

- [ ] Create MetaMask Embedded Wallets project
- [ ] Add ChainID 138 as custom network in dashboard
- [ ] Configure branding (logo, colors, theme)
- [ ] Configure login modal appearance
- [ ] Set up authentication methods
- [ ] Configure external wallet detection
- [ ] Add token list URL
- [ ] Test embedded wallet connection
- [ ] Test token display
- [ ] Test transactions

---

## Next Steps

1. **Get Client ID**: Register project in MetaMask dashboard
2. **Configure Network**: Add ChainID 138 via dashboard
3. **Integrate SDK**: Add Web3Auth SDK to your dApp
4. **Test Integration**: Test wallet connection and transactions
5. **Deploy**: Deploy to production

---

## Resources

- [MetaMask Embedded Wallets Docs](https://docs.metamask.io/embedded-wallets/)
- [Chains and Networks Configuration](https://docs.metamask.io/embedded-wallets/dashboard/chains-and-networks/)
- [Customization Guide](https://docs.metamask.io/embedded-wallets/dashboard/customization/)
- [Web3Auth Documentation](https://web3auth.io/docs/)

---

**Last Updated**: 2026-01-26
