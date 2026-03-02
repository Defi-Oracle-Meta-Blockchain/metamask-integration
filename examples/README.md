# Smart Accounts Examples

Complete examples demonstrating Smart Accounts Kit integration on ChainID 138.

---

## Available Examples

### 1. TypeScript Example (`smart-accounts-example.ts`)

**Type**: TypeScript/Node.js  
**Use Case**: Backend integration, testing, automation

**Features**:
- Complete Smart Accounts Kit integration
- Account creation
- Delegation management
- Permission requests
- Batch operations
- AccountWalletRegistry integration

**Usage**:
```bash
# Install dependencies
npm install

# Run with ts-node
npx ts-node examples/smart-accounts-example.ts
```

---

### 2. React Example (`smart-accounts-react-example/`)

**Type**: React + TypeScript  
**Use Case**: Frontend dApp integration

**Features**:
- React hooks for Smart Accounts
- Wallet connection
- Smart Account creation
- Delegation UI
- Real-time status updates

**Usage**:
```bash
cd examples/smart-accounts-react-example
npm install
npm start
```

**Documentation**: See `smart-accounts-react-example/README.md`

---

### 3. Vue.js Example (`smart-accounts-vue-example/`)

**Type**: Vue 3 + TypeScript  
**Use Case**: Frontend dApp integration (Vue ecosystem)

**Features**:
- Vue 3 Composition API
- Wallet connection
- Smart Account creation
- Delegation UI
- Reactive state management

**Usage**:
```bash
cd examples/smart-accounts-vue-example
npm install
npm run dev
```

**Documentation**: See `smart-accounts-vue-example/README.md`

---

### 4. HTML/JavaScript Example (`smart-accounts-example.html`)

**Type**: Vanilla HTML/JavaScript  
**Use Case**: Simple demos, quick prototypes, learning

**Features**:
- No build step required
- Simple HTML page
- Basic Smart Accounts functionality
- Easy to understand and modify

**Usage**:
```bash
# Open in browser
open examples/smart-accounts-example.html
```

**Note**: This is a simplified example. For production, use React or Vue examples.

---

## Configuration

All examples require configuration with deployed contract addresses:

1. **Deploy contracts** (see [Deployment Guide](../docs/QUICK_START_DEPLOYMENT.md))
2. **Update configuration** in `config/smart-accounts-config.json`:
   ```json
   {
     "chainId": 138,
     "rpcUrl": "https://rpc.d-bis.org",
     "entryPointAddress": "0x...",
     "accountFactoryAddress": "0x...",
     "paymasterAddress": "0x..." // optional
   }
   ```
3. **Update examples** to load configuration

---

## Common Features

All examples demonstrate:

1. **Wallet Connection**: Connect to MetaMask
2. **Smart Account Creation**: Create a new Smart Account
3. **Delegation**: Request and manage delegations
4. **Permissions**: Request Advanced Permissions (ERC-7715)
5. **Batch Operations**: Execute multiple operations in one transaction

---

## Documentation

- [Developer Guide](../docs/SMART_ACCOUNTS_DEVELOPER_GUIDE.md)
- [API Reference](../docs/SMART_ACCOUNTS_API_REFERENCE.md)
- [Delegation Guide](../docs/DELEGATION_USAGE_GUIDE.md)
- [Advanced Permissions Guide](../docs/ADVANCED_PERMISSIONS_GUIDE.md)
- [Quick Start Deployment](../docs/QUICK_START_DEPLOYMENT.md)

---

## Requirements

### Prerequisites

- **MetaMask**: Installed and configured
- **Node.js**: v18 or higher (for React/Vue examples)
- **Network**: ChainID 138 added to MetaMask
- **Contracts**: Smart Accounts contracts deployed

### Dependencies

- `@metamask/smart-accounts-kit`: Smart Accounts Kit SDK
- `ethers`: Ethereum library (v6.0.0+)

---

## Getting Started

1. **Choose an example** based on your framework preference
2. **Install dependencies**: `npm install`
3. **Configure**: Update configuration with contract addresses
4. **Run**: Follow example-specific instructions
5. **Test**: Connect wallet and create Smart Account

---

## Support

For issues or questions:
- Check [Troubleshooting Guide](../docs/SMART_ACCOUNTS_TROUBLESHOOTING.md)
- Review [FAQ](../docs/SMART_ACCOUNTS_FAQ.md)
- See [Developer Guide](../docs/SMART_ACCOUNTS_DEVELOPER_GUIDE.md)

---

**Last Updated**: 2026-01-26
