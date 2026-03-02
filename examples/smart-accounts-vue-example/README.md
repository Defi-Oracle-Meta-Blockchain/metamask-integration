# Smart Accounts Vue.js Example

Complete Vue.js example demonstrating Smart Accounts Kit integration on ChainID 138.

## Features

- Connect to MetaMask
- Create Smart Accounts
- Request Delegations
- View Delegation Status
- Batch Operations (coming soon)

## Installation

```bash
npm install
```

## Configuration

Update `src/App.vue` to use your configuration:

```typescript
const config = require('../../config/smart-accounts-config.json');
```

Or create a local config file with your deployed contract addresses.

## Running

```bash
npm run dev
```

The app will open at `http://localhost:5173` (or similar port).

## Usage

1. **Connect Wallet**: Click "Connect MetaMask" to connect your wallet
2. **Create Smart Account**: Click "Create Smart Account" to create a new Smart Account
3. **Request Delegation**: Request delegation for a dApp or service
4. **View Status**: View delegation status and expiry

## Documentation

- [Developer Guide](../../docs/SMART_ACCOUNTS_API_REFERENCE.md)
- [API Reference](../../docs/SMART_ACCOUNTS_API_REFERENCE.md)
- [Delegation Guide](../../docs/SMART_ACCOUNTS_FAQ.md)

## License

See parent repository for license information.
