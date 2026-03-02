#!/bin/bash

# Deploy MetaMask Smart Accounts Kit for ChainID 138
# This script prepares deployment configuration for Smart Accounts Kit

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

log_info "========================================="
log_info "MetaMask Smart Accounts Kit Deployment"
log_info "========================================="
log_info ""

# Create deployment directory
DEPLOY_DIR="$PROJECT_ROOT/smart-accounts-kit-deployment"
mkdir -p "$DEPLOY_DIR"

# Create deployment guide
log_info "Creating deployment guide..."
cat > "$DEPLOY_DIR/DEPLOYMENT_GUIDE.md" << 'EOF'
# MetaMask Smart Accounts Kit Deployment Guide

**Reference**: [MetaMask Smart Accounts Kit Documentation](https://docs.metamask.io/smart-accounts-kit#partner-integrations)

---

## Overview

MetaMask Smart Accounts Kit enables:
- Programmable account behavior
- Delegation framework
- Advanced Permissions (ERC-7715)
- User operation batching
- Gas abstraction

---

## Installation

### NPM Installation

```bash
npm install @metamask/smart-accounts-kit
```

### Yarn Installation

```bash
yarn add @metamask/smart-accounts-kit
```

### PNPM Installation

```bash
pnpm add @metamask/smart-accounts-kit
```

---

## Configuration

### ChainID 138 Configuration

```typescript
import { SmartAccountsKit } from '@metamask/smart-accounts-kit';

const smartAccountsKit = new SmartAccountsKit({
  chainId: 138,
  rpcUrl: 'https://rpc.d-bis.org',
  entryPointAddress: '0x...', // EntryPoint contract address
  accountFactoryAddress: '0x...', // AccountFactory contract address
});
```

---

## Deployment Steps

### Step 1: Deploy EntryPoint Contract

The EntryPoint contract handles user operations.

```bash
# Deploy EntryPoint
forge script script/DeployEntryPoint.s.sol --rpc-url $RPC_URL_138
```

### Step 2: Deploy AccountFactory Contract

The AccountFactory creates smart accounts.

```bash
# Deploy AccountFactory
forge script script/DeployAccountFactory.s.sol --rpc-url $RPC_URL_138
```

### Step 3: Deploy Paymaster Contract (Optional)

For gas abstraction, deploy a Paymaster contract.

```bash
# Deploy Paymaster
forge script script/DeployPaymaster.s.sol --rpc-url $RPC_URL_138
```

### Step 4: Configure SDK

```typescript
import { SmartAccountsKit } from '@metamask/smart-accounts-kit';

const kit = new SmartAccountsKit({
  chainId: 138,
  rpcUrl: 'https://rpc.d-bis.org',
  entryPointAddress: '0x...',
  accountFactoryAddress: '0x...',
  paymasterAddress: '0x...', // Optional
});
```

---

## Integration with AccountWalletRegistry

### Extend AccountWalletRegistry

Add smart account support to existing AccountWalletRegistry:

```solidity
// Add to AccountWalletRegistry
function linkSmartAccountToWallet(
    bytes32 accountRefId,
    address smartAccount,
    bytes32 provider
) external onlyRole(ACCOUNT_MANAGER_ROLE) {
    bytes32 walletRefId = keccak256(abi.encodePacked(smartAccount));
    linkAccountToWallet(accountRefId, walletRefId, provider);
}
```

---

## Features

### 1. Create Smart Account

```typescript
const smartAccount = await kit.createAccount({
  owner: userAddress,
  salt: '0x...', // Optional
});
```

### 2. Request Delegation

```typescript
const delegation = await kit.requestDelegation({
  target: dAppAddress,
  permissions: ['execute_transactions'],
  expiry: Date.now() + 86400000,
});
```

### 3. Advanced Permissions (ERC-7715)

```typescript
const permission = await kit.requestAdvancedPermission({
  target: dAppAddress,
  functionSelector: '0x...',
  allowed: true,
});
```

### 4. Batch User Operations

```typescript
const userOps = await kit.batchUserOperations([
  { to: tokenAddress, data: transferData },
  { to: anotherAddress, data: anotherData },
]);
```

---

## Testing

### Test Smart Account Creation

```typescript
const account = await kit.createAccount({ owner: userAddress });
console.log('Smart Account:', account.address);
```

### Test Delegation

```typescript
const delegation = await kit.requestDelegation({
  target: dAppAddress,
  permissions: ['execute_transactions'],
});
console.log('Delegation approved:', delegation.approved);
```

---

## Next Steps

1. Deploy contracts to ChainID 138
2. Configure SDK
3. Integrate with AccountWalletRegistry
4. Test all features
5. Deploy to production

---

**Last Updated**: 2026-01-26
EOF

log_success "Created: $DEPLOY_DIR/DEPLOYMENT_GUIDE.md"

# Create integration guide
cat > "$DEPLOY_DIR/ACCOUNT_WALLET_INTEGRATION.md" << 'EOF'
# Smart Accounts Kit + AccountWalletRegistry Integration

## Overview

Integrate MetaMask Smart Accounts Kit with existing AccountWalletRegistry to enable:
- Smart accounts linked to fiat accounts
- Delegation for payment rails
- Advanced permissions for dApps
- Enhanced user experience

## Integration Architecture

```
┌─────────────────────┐
│  Fiat Account       │
│  (IBAN/ABA)         │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ AccountWalletRegistry│
│  (Existing)          │
└──────────┬──────────┘
           │
           ├──► EOA Wallet (MetaMask)
           │
           └──► Smart Account (New)
                  │
                  ├──► Delegation Framework
                  ├──► Advanced Permissions
                  └──► User Operations
```

## Implementation

### 1. Extend AccountWalletRegistry

Add smart account support:

```solidity
// Add to AccountWalletRegistry.sol
function linkSmartAccount(
    bytes32 accountRefId,
    address smartAccount,
    bytes32 provider
) external onlyRole(ACCOUNT_MANAGER_ROLE) {
    bytes32 walletRefId = keccak256(abi.encodePacked(smartAccount));
    linkAccountToWallet(accountRefId, walletRefId, provider);
}

function isSmartAccount(bytes32 walletRefId) external view returns (bool) {
    // Check if wallet is a smart account
    // Implementation depends on smart account detection
}
```

### 2. Create Smart Account on Link

```typescript
// When linking account to wallet, create smart account if needed
async function linkAccountWithSmartAccount(
  accountRefId: string,
  userAddress: string
) {
  // Create smart account
  const smartAccount = await smartAccountsKit.createAccount({
    owner: userAddress,
  });
  
  // Link to AccountWalletRegistry
  await accountWalletRegistry.linkSmartAccount(
    accountRefId,
    smartAccount.address,
    'METAMASK_SMART_ACCOUNT'
  );
}
```

### 3. Use Smart Account for Payments

```typescript
// Use smart account for payment rail operations
async function initiatePayment(
  accountRefId: string,
  amount: bigint,
  token: string
) {
  // Get smart account from registry
  const wallets = await accountWalletRegistry.getWallets(accountRefId);
  const smartAccount = wallets.find(w => w.provider === 'METAMASK_SMART_ACCOUNT');
  
  // Use smart account for settlement
  await settlementOrchestrator.validateAndLock(triggerId, {
    account: smartAccount.address,
    amount,
    token,
  });
}
```

---

## Benefits

1. **Enhanced Capabilities**: Smart accounts enable delegation and permissions
2. **Better UX**: Gas abstraction and batch operations
3. **Compliance**: Maintain compliance with smart accounts
4. **Flexibility**: Support both EOA and smart accounts

---

**Last Updated**: 2026-01-26
EOF

log_success "Created: $DEPLOY_DIR/ACCOUNT_WALLET_INTEGRATION.md"

log_info ""
log_info "========================================="
log_info "Smart Accounts Kit Config Complete!"
log_info "========================================="
log_info ""
log_info "Files created in: $DEPLOY_DIR"
log_info "  - DEPLOYMENT_GUIDE.md (deployment guide)"
log_info "  - ACCOUNT_WALLET_INTEGRATION.md (integration guide)"
log_info ""
log_info "Next steps:"
log_info "1. Review deployment guide"
log_info "2. Deploy Smart Accounts Kit contracts"
log_info "3. Integrate with AccountWalletRegistry"
log_info "4. Test smart account features"
log_info ""
