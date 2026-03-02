# MetaMask SDK API Reference

Complete API reference for the MetaMask SDK for ChainID 138.

## Installation

```bash
npm install @defi-oracle/metamask-sdk
# or
cd smom-dbis-138/metamask-sdk
npm install
```

## Import

```typescript
import {
  addNetwork,
  switchNetwork,
  addOrSwitchNetwork,
  isNetworkAdded,
  isOnChain138,
  getCurrentChainId,
  addToken,
  addTokenFromList,
  CHAIN_ID,
  CHAIN_ID_HEX,
  CHAIN_NAME,
  RPC_URLS,
  BLOCK_EXPLORER_URL,
  NETWORK_METADATA,
} from '@defi-oracle/metamask-sdk';
```

---

## Network Functions

### `addNetwork(customMetadata?)`

Adds ChainID 138 to MetaMask.

**Parameters**:
- `customMetadata?` (optional): Custom network metadata to override defaults

**Returns**: `Promise<void>`

**Throws**:
- `Error` if MetaMask is not installed
- `Error` if user rejects the request
- `Error` if network addition fails

**Example**:
```typescript
try {
  await addNetwork();
  console.log('ChainID 138 added to MetaMask');
} catch (error) {
  console.error('Failed to add network:', error);
}
```

---

### `switchNetwork()`

Switches MetaMask to ChainID 138.

**Returns**: `Promise<void>`

**Throws**:
- `Error` if MetaMask is not installed
- `Error` if ChainID 138 is not added (use `addNetwork()` first)
- `Error` if user rejects the request
- `Error` if network switch fails

**Example**:
```typescript
try {
  await switchNetwork();
  console.log('Switched to ChainID 138');
} catch (error) {
  if (error.code === 4902) {
    // Chain not added, add it first
    await addNetwork();
  } else {
    console.error('Failed to switch network:', error);
  }
}
```

---

### `addOrSwitchNetwork()`

Adds ChainID 138 if not added, or switches to it if already added.

**Returns**: `Promise<void>`

**Throws**:
- `Error` if MetaMask is not installed
- `Error` if user rejects the request
- `Error` if operation fails

**Example**:
```typescript
try {
  await addOrSwitchNetwork();
  console.log('Connected to ChainID 138');
} catch (error) {
  console.error('Failed to connect:', error);
}
```

---

### `isNetworkAdded()`

Checks if ChainID 138 is already added to MetaMask.

**Returns**: `Promise<boolean>`

**Throws**:
- `Error` if MetaMask is not installed

**Example**:
```typescript
const isAdded = await isNetworkAdded();
if (isAdded) {
  console.log('ChainID 138 is already added');
} else {
  console.log('ChainID 138 is not added');
}
```

---

### `isOnChain138()`

Checks if MetaMask is currently connected to ChainID 138.

**Returns**: `Promise<boolean>`

**Throws**:
- `Error` if MetaMask is not installed

**Example**:
```typescript
const isOn138 = await isOnChain138();
if (isOn138) {
  console.log('Currently on ChainID 138');
} else {
  console.log('Not on ChainID 138');
}
```

---

### `getCurrentChainId()`

Gets the current chain ID from MetaMask.

**Returns**: `Promise<number>`

**Throws**:
- `Error` if MetaMask is not installed

**Example**:
```typescript
const chainId = await getCurrentChainId();
console.log('Current chain ID:', chainId);
if (chainId === 138) {
  console.log('On ChainID 138');
}
```

---

## Token Functions

### `addToken(address, symbol, decimals, image?)`

Adds an ERC-20 token to MetaMask.

**Parameters**:
- `address` (string): Token contract address
- `symbol` (string): Token symbol (e.g., "cUSDT")
- `decimals` (number): Token decimals (e.g., 6 for cUSDT)
- `image?` (optional string): Token logo URL

**Returns**: `Promise<void>`

**Throws**:
- `Error` if MetaMask is not installed
- `Error` if user rejects the request
- `Error` if token addition fails

**Example**:
```typescript
try {
  await addToken(
    '0x93E66202A11B1772E55407B32B44e5Cd8eda7f22',
    'cUSDT',
    6,
    'https://explorer.d-bis.org/images/tokens/0x93E66202A11B1772E55407B32B44e5Cd8eda7f22.png'
  );
  console.log('cUSDT added to MetaMask');
} catch (error) {
  console.error('Failed to add token:', error);
}
```

---

### `addTokenFromList(token)`

Adds a token from a token list entry.

**Parameters**:
- `token` (object): Token list entry with `address`, `symbol`, `decimals`, `logoURI`

**Returns**: `Promise<void>`

**Example**:
```typescript
const token = {
  address: '0x93E66202A11B1772E55407B32B44e5Cd8eda7f22',
  symbol: 'cUSDT',
  decimals: 6,
  logoURI: 'https://explorer.d-bis.org/images/tokens/0x93E66202A11B1772E55407B32B44e5Cd8eda7f22.png'
};

try {
  await addTokenFromList(token);
  console.log('Token added from list');
} catch (error) {
  console.error('Failed to add token:', error);
}
```

---

## Constants

### `CHAIN_ID`
Chain ID number: `138`

### `CHAIN_ID_HEX`
Chain ID in hex: `'0x8a'`

### `CHAIN_NAME`
Chain name: `'DeFi Oracle Meta Mainnet'`

### `RPC_URLS`
Array of RPC endpoint URLs:
```typescript
[
  'https://rpc.d-bis.org',
  'https://rpc2.d-bis.org'
]
```

### `BLOCK_EXPLORER_URL`
Block explorer URL: `'https://explorer.d-bis.org'`

### `NETWORK_METADATA`
Complete network metadata for `wallet_addEthereumChain`:
```typescript
{
  chainId: '0x8a',
  chainName: 'DeFi Oracle Meta Mainnet',
  nativeCurrency: {
    name: 'Ether',
    symbol: 'ETH',
    decimals: 18,
  },
  rpcUrls: ['https://rpc.d-bis.org', 'https://rpc2.d-bis.org'],
  blockExplorerUrls: ['https://explorer.d-bis.org'],
}
```

---

## Error Handling

All functions can throw errors. Always use try-catch:

```typescript
try {
  await addNetwork();
} catch (error: any) {
  if (error.message?.includes('MetaMask is not installed')) {
    // Handle MetaMask not installed
    alert('Please install MetaMask');
  } else if (error.code === 4001) {
    // User rejected the request
    console.log('User rejected network addition');
  } else {
    // Other errors
    console.error('Error:', error);
  }
}
```

### Common Error Codes

- `4001`: User rejected the request
- `4902`: Chain not added (for switchNetwork)
- `-32603`: Internal JSON-RPC error
- `-32002`: Request already pending

---

## Complete Examples

### React Hook Example

```typescript
import { useState, useEffect } from 'react';
import { addOrSwitchNetwork, isOnChain138, addToken } from '@defi-oracle/metamask-sdk';

function useChain138() {
  const [isConnected, setIsConnected] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const connect = async () => {
    setIsLoading(true);
    setError(null);
    
    try {
      await addOrSwitchNetwork();
      const isOn138 = await isOnChain138();
      setIsConnected(isOn138);
    } catch (err: any) {
      setError(err.message);
      setIsConnected(false);
    } finally {
      setIsLoading(false);
    }
  };

  return { isConnected, isLoading, error, connect };
}
```

### Vue Composable Example

```typescript
import { ref } from 'vue';
import { addOrSwitchNetwork, isOnChain138, addToken } from '@defi-oracle/metamask-sdk';

export function useChain138() {
  const isConnected = ref(false);
  const isLoading = ref(false);
  const error = ref<string | null>(null);

  const connect = async () => {
    isLoading.value = true;
    error.value = null;
    
    try {
      await addOrSwitchNetwork();
      const isOn138 = await isOnChain138();
      isConnected.value = isOn138;
    } catch (err: any) {
      error.value = err.message;
      isConnected.value = false;
    } finally {
      isLoading.value = false;
    }
  };

  return { isConnected, isLoading, error, connect };
}
```

---

## TypeScript Types

```typescript
// Network metadata type
interface NetworkMetadata {
  chainId: string;
  chainName: string;
  nativeCurrency: {
    name: string;
    symbol: string;
    decimals: number;
  };
  rpcUrls: string[];
  blockExplorerUrls: string[];
  iconUrls?: string[];
}

// Token metadata type
interface TokenMetadata {
  address: string;
  symbol: string;
  decimals: number;
  image?: string;
}
```

---

## Browser Compatibility

- ✅ Chrome/Chromium (MetaMask Extension)
- ✅ Firefox (MetaMask Extension)
- ✅ Edge (MetaMask Extension)
- ✅ Brave (MetaMask Extension)
- ✅ MetaMask Mobile (in-app browser)

---

## Requirements

- MetaMask extension or mobile app installed
- MetaMask unlocked
- User approval for network/token operations

---

**Last Updated**: 2026-01-26
