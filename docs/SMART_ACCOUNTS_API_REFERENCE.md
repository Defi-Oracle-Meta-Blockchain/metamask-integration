# Smart Accounts API Reference

**Date**: 2026-01-26  
**Network**: ChainID 138 (SMOM-DBIS-138)

---

## Overview

Complete API reference for Smart Accounts Kit integration.

---

## SmartAccountsKit Class

### Constructor

```typescript
new SmartAccountsKit(options: SmartAccountsKitOptions)
```

**Options**:
```typescript
interface SmartAccountsKitOptions {
  chainId: number;
  rpcUrl: string;
  entryPointAddress: string;
  accountFactoryAddress: string;
  paymasterAddress?: string;
}
```

**Example**:
```typescript
const kit = new SmartAccountsKit({
  chainId: 138,
  rpcUrl: 'https://rpc.d-bis.org',
  entryPointAddress: '0x...',
  accountFactoryAddress: '0x...',
});
```

---

## Methods

### createAccount()

Creates a new Smart Account.

```typescript
createAccount(options: CreateAccountOptions): Promise<SmartAccount>
```

**Options**:
```typescript
interface CreateAccountOptions {
  owner: string;
  salt?: string;
}
```

**Returns**: `Promise<SmartAccount>`

**Example**:
```typescript
const account = await kit.createAccount({
  owner: userAddress,
});
```

---

### requestDelegation()

Requests delegation from user.

```typescript
requestDelegation(options: DelegationOptions): Promise<DelegationResult>
```

**Options**:
```typescript
interface DelegationOptions {
  target: string;
  permissions: string[];
  expiry: number;
  rules?: DelegationRules;
}
```

**Returns**: `Promise<DelegationResult>`

**Example**:
```typescript
const delegation = await kit.requestDelegation({
  target: dAppAddress,
  permissions: ['execute_transactions'],
  expiry: Date.now() + 86400000,
});
```

---

### getDelegationStatus()

Gets delegation status.

```typescript
getDelegationStatus(options: DelegationStatusOptions): Promise<DelegationStatus>
```

**Options**:
```typescript
interface DelegationStatusOptions {
  target: string;
  account: string;
}
```

**Returns**: `Promise<DelegationStatus>`

**Example**:
```typescript
const status = await kit.getDelegationStatus({
  target: dAppAddress,
  account: smartAccountAddress,
});
```

---

### revokeDelegation()

Revokes delegation.

```typescript
revokeDelegation(options: RevokeDelegationOptions): Promise<void>
```

**Options**:
```typescript
interface RevokeDelegationOptions {
  target: string;
  account: string;
}
```

**Example**:
```typescript
await kit.revokeDelegation({
  target: dAppAddress,
  account: smartAccountAddress,
});
```

---

### requestAdvancedPermission()

Requests Advanced Permission (ERC-7715).

```typescript
requestAdvancedPermission(options: PermissionOptions): Promise<PermissionResult>
```

**Options**:
```typescript
interface PermissionOptions {
  target: string;
  functionSelector: string;
  allowed: boolean;
  conditions?: PermissionConditions;
}
```

**Returns**: `Promise<PermissionResult>`

**Example**:
```typescript
const permission = await kit.requestAdvancedPermission({
  target: contractAddress,
  functionSelector: '0xa9059cbb',
  allowed: true,
});
```

---

### hasPermission()

Checks if permission is granted.

```typescript
hasPermission(options: CheckPermissionOptions): Promise<boolean>
```

**Options**:
```typescript
interface CheckPermissionOptions {
  account: string;
  target: string;
  functionSelector: string;
}
```

**Returns**: `Promise<boolean>`

**Example**:
```typescript
const hasPermission = await kit.hasPermission({
  account: smartAccountAddress,
  target: contractAddress,
  functionSelector: '0xa9059cbb',
});
```

---

### batchUserOperations()

Creates batch of user operations.

```typescript
batchUserOperations(operations: UserOperation[]): Promise<UserOperation[]>
```

**Operations**:
```typescript
interface UserOperation {
  to: string;
  data: string;
  value: string;
}
```

**Returns**: `Promise<UserOperation[]>`

**Example**:
```typescript
const userOps = await kit.batchUserOperations([
  {
    to: tokenAddress,
    data: transferData,
    value: '0',
  },
]);
```

---

### executeBatch()

Executes batch of user operations.

```typescript
executeBatch(userOps: UserOperation[]): Promise<TransactionResult>
```

**Returns**: `Promise<TransactionResult>`

**Example**:
```typescript
const result = await kit.executeBatch(userOps);
console.log('Transaction hash:', result.hash);
```

---

## AccountWalletRegistryExtended Contract

### linkSmartAccount()

Links Smart Account to fiat account.

```solidity
function linkSmartAccount(
    bytes32 accountRefId,
    address smartAccount,
    bytes32 provider
) external onlyRole(ACCOUNT_MANAGER_ROLE)
```

**Parameters**:
- `accountRefId`: Hashed account reference ID
- `smartAccount`: Smart Account address
- `provider`: Provider identifier (e.g., "METAMASK_SMART_ACCOUNT")

**Events**:
- `SmartAccountLinked(accountRefId, smartAccount, provider)`

---

### isSmartAccount()

Checks if wallet is Smart Account.

```solidity
function isSmartAccount(bytes32 walletRefId) external view returns (bool)
```

**Parameters**:
- `walletRefId`: Hashed wallet reference ID

**Returns**: `bool`

---

### isSmartAccountAddress()

Checks if address is Smart Account.

```solidity
function isSmartAccountAddress(address accountAddress) external view returns (bool)
```

**Parameters**:
- `accountAddress`: Account address to check

**Returns**: `bool`

---

## Error Handling

### Common Errors

**USER_REJECTED**:
- User rejected transaction
- Handle gracefully

**INSUFFICIENT_FUNDS**:
- Insufficient ETH for gas
- Prompt user to add funds

**PERMISSION_DENIED**:
- Permission not granted
- Request permission first

**DELEGATION_EXPIRED**:
- Delegation has expired
- Request new delegation

---

## Resources

- [Developer Guide](./SMART_ACCOUNTS_DEVELOPER_GUIDE.md)
- [Delegation Guide](./DELEGATION_USAGE_GUIDE.md)
- [Permissions Guide](./ADVANCED_PERMISSIONS_GUIDE.md)

---

**Last Updated**: 2026-01-26
