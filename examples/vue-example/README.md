# MetaMask ChainID 138 Vue.js Example

Complete Vue.js 3 example for integrating MetaMask with ChainID 138.

## Features

- ✅ Connect to MetaMask wallet
- ✅ Add ChainID 138 network
- ✅ Switch to ChainID 138 network
- ✅ Add tokens (cUSDT, cUSDC, WETH)
- ✅ Display wallet balance
- ✅ Error handling
- ✅ TypeScript support

## Installation

```bash
npm install
```

## Development

```bash
npm run dev
```

## Build

```bash
npm run build
```

## Usage

1. Install MetaMask browser extension
2. Open the application
3. Click "Connect Wallet"
4. Approve connection in MetaMask
5. Add ChainID 138 network if needed
6. Add tokens to MetaMask

## Code Structure

- `App.vue` - Main component with wallet connection logic
- Uses Composition API with `<script setup>`
- Uses `ethers.js` v6 for blockchain interactions

## Network Configuration

The example includes ChainID 138 network configuration:
- Chain ID: 138 (0x8a)
- RPC URLs: https://rpc.d-bis.org, https://rpc2.d-bis.org
- Explorer: https://explorer.d-bis.org

## Token Addresses

- cUSDT: `0x93E66202A11B1772E55407B32B44e5Cd8eda7f22` (6 decimals)
- cUSDC: `0xf22258f57794CC8E06237084b353Ab30fFfa640b` (6 decimals)
- WETH: `0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2` (18 decimals)
