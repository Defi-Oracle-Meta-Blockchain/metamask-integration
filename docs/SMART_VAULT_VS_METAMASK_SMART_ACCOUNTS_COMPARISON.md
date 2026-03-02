# Smart Vault vs MetaMask Smart Accounts Kit - Comparison

**Date**: 2026-01-26  
**Reference**: [MetaMask Smart Accounts Kit Documentation](https://docs.metamask.io/smart-accounts-kit#partner-integrations)

---

## Executive Summary

The Proxmox project contains **RailEscrowVault** and **AccountWalletRegistry** systems, which serve different purposes than MetaMask Smart Accounts Kit. This document compares the two systems and outlines integration opportunities.

---

## System Comparison

### MetaMask Smart Accounts Kit

**Purpose**: Enable programmable account behavior and granular permission sharing for MetaMask users.

**Key Features**:
- ✅ **Smart Accounts**: Programmable accounts with custom logic
- ✅ **Delegation Framework**: Rule-based permission sharing
- ✅ **Advanced Permissions (ERC-7715)**: Fine-grained permissions for dApps
- ✅ **User Operations**: Batch transactions and gas abstraction
- ✅ **Multi-Signature**: Multi-sig approvals
- ✅ **Gas Abstraction**: Pay gas in tokens or sponsor gas

**Use Cases**:
- Execute on behalf of users
- Batch multiple transactions
- Share permissions with dApps
- Programmable account behavior

---

### Proxmox Smart Vault System

**Components**:

#### 1. RailEscrowVault

**Purpose**: Holds tokens locked for outbound rail transfers (payment rails like FEDWIRE, SWIFT, SEPA).

**Key Features**:
- ✅ **Token Escrow**: Locks tokens for payment rail transfers
- ✅ **Per-Trigger Tracking**: Tracks escrow by trigger ID
- ✅ **Role-Based Access**: SETTLEMENT_OPERATOR_ROLE required
- ✅ **Lock/Release**: Lock tokens for settlement, release after completion

**Address**: `0x609644D9858435f908A5B8528941827dDD13a346`

**Use Cases**:
- Lock tokens for FEDWIRE transfers
- Lock tokens for SWIFT transfers
- Lock tokens for SEPA transfers
- Manage escrow for payment rails

#### 2. AccountWalletRegistry

**Purpose**: Maps regulated fiat accounts (IBAN, ABA) to Web3 wallets.

**Key Features**:
- ✅ **Account-Wallet Mapping**: Links fiat accounts to wallets
- ✅ **Provider Support**: Supports MetaMask, Fireblocks, etc.
- ✅ **1-to-Many Mapping**: One account can link to multiple wallets
- ✅ **Active/Inactive Links**: Can activate/deactivate links
- ✅ **Privacy**: Stores hashed references (no PII on-chain)

**Address**: `0xBeEF0128B7ff030e25beeda6Ff62f02041Dedbd0`

**Use Cases**:
- Link IBAN to MetaMask wallet
- Link ABA routing to wallet
- Track wallet providers
- Manage account-wallet relationships

#### 3. SettlementOrchestrator

**Purpose**: Coordinates trigger lifecycle and fund locking/release.

**Key Features**:
- ✅ **Trigger Validation**: Validates payment triggers
- ✅ **Compliance Checks**: Checks compliance registry
- ✅ **Policy Enforcement**: Enforces policy manager rules
- ✅ **Escrow Management**: Manages vault or lien escrow
- ✅ **Rail Integration**: Integrates with payment rails

**Use Cases**:
- Coordinate payment settlements
- Validate compliance
- Enforce policies
- Manage escrow lifecycle

---

## Feature Comparison Matrix

| Feature | MetaMask Smart Accounts Kit | Proxmox Smart Vault System |
|---------|----------------------------|---------------------------|
| **Programmable Accounts** | ✅ Yes (Smart Accounts) | ❌ No (Standard EOAs) |
| **Delegation Framework** | ✅ Yes (Rule-based) | ❌ No |
| **Advanced Permissions (ERC-7715)** | ✅ Yes | ❌ No |
| **User Operations** | ✅ Yes (Batch transactions) | ❌ No |
| **Gas Abstraction** | ✅ Yes | ❌ No |
| **Multi-Signature** | ✅ Yes | ❌ No |
| **Token Escrow** | ❌ No | ✅ Yes (RailEscrowVault) |
| **Account-Wallet Mapping** | ❌ No | ✅ Yes (AccountWalletRegistry) |
| **Payment Rail Integration** | ❌ No | ✅ Yes (SettlementOrchestrator) |
| **Compliance Integration** | ❌ No | ✅ Yes (ComplianceRegistry) |
| **Policy Enforcement** | ❌ No | ✅ Yes (PolicyManager) |

---

## Key Differences

### 1. Purpose

**MetaMask Smart Accounts Kit**:
- Focus: User experience and dApp integration
- Goal: Enable programmable accounts and permission sharing
- Target: End users and dApp developers

**Proxmox Smart Vault System**:
- Focus: Payment rail settlement and compliance
- Goal: Manage escrow for traditional payment rails
- Target: Financial institutions and regulated entities

### 2. Architecture

**MetaMask Smart Accounts Kit**:
- Smart contract accounts (ERC-4337 compatible)
- Delegation framework
- Permission system (ERC-7715)
- User operation batching

**Proxmox Smart Vault System**:
- Standard EOAs (Externally Owned Accounts)
- Escrow vault contracts
- Account-wallet registry
- Settlement orchestration

### 3. Use Cases

**MetaMask Smart Accounts Kit**:
- Execute transactions on behalf of users
- Batch multiple operations
- Share permissions with dApps
- Gas abstraction

**Proxmox Smart Vault System**:
- Lock tokens for payment rail transfers
- Map fiat accounts to wallets
- Coordinate payment settlements
- Enforce compliance and policies

---

## Integration Opportunities

### Option 1: Add MetaMask Smart Accounts Kit Support

**Benefits**:
- Enable programmable accounts for ChainID 138
- Support delegation and advanced permissions
- Enable gas abstraction
- Support user operation batching

**Implementation**:
1. Deploy MetaMask Smart Accounts Kit contracts
2. Integrate with existing AccountWalletRegistry
3. Add delegation framework
4. Support ERC-7715 Advanced Permissions

**Files to Create**:
- Smart Accounts deployment scripts
- Delegation integration guide
- Advanced Permissions setup
- Integration with AccountWalletRegistry

### Option 2: Enhance AccountWalletRegistry with Smart Account Features

**Benefits**:
- Add programmable behavior to registered wallets
- Enable delegation for payment rails
- Support batch operations
- Add permission framework

**Implementation**:
1. Extend AccountWalletRegistry to support smart accounts
2. Add delegation capabilities
3. Integrate with MetaMask Smart Accounts Kit
4. Support both standard and smart accounts

### Option 3: Hybrid Approach

**Benefits**:
- Keep existing RailEscrowVault for payment rails
- Add Smart Accounts for dApp interactions
- Support both use cases

**Implementation**:
1. Deploy MetaMask Smart Accounts Kit
2. Keep RailEscrowVault for payment rails
3. Use Smart Accounts for dApp interactions
4. Bridge between systems via AccountWalletRegistry

---

## Recommended Integration Path

### Phase 1: Deploy MetaMask Smart Accounts Kit

1. **Deploy Smart Accounts Contracts**:
   - Deploy MetaMask Smart Accounts Kit contracts
   - Configure for ChainID 138
   - Set up delegation framework

2. **Integrate with AccountWalletRegistry**:
   - Extend AccountWalletRegistry to support smart accounts
   - Link smart accounts to fiat accounts
   - Support both EOA and smart accounts

3. **Add Delegation Support**:
   - Implement delegation framework
   - Support rule-based permissions
   - Enable dApp permissions

### Phase 2: Advanced Features

1. **ERC-7715 Advanced Permissions**:
   - Implement Advanced Permissions standard
   - Enable fine-grained dApp permissions
   - Support permission requests from MetaMask

2. **Gas Abstraction**:
   - Enable gas payment in tokens
   - Support gas sponsorship
   - Batch operations for efficiency

3. **User Operations**:
   - Support user operation batching
   - Enable transaction batching
   - Optimize gas usage

---

## Integration Guide Structure

### 1. Smart Accounts Deployment

**File**: `docs/SMART_ACCOUNTS_DEPLOYMENT.md`

- Deploy MetaMask Smart Accounts Kit
- Configure for ChainID 138
- Set up delegation framework
- Test smart account creation

### 2. AccountWalletRegistry Integration

**File**: `docs/SMART_ACCOUNTS_ACCOUNT_WALLET_INTEGRATION.md`

- Extend AccountWalletRegistry
- Support smart account addresses
- Link smart accounts to fiat accounts
- Manage smart account lifecycle

### 3. Delegation Framework

**File**: `docs/SMART_ACCOUNTS_DELEGATION.md`

- Implement delegation framework
- Create delegation rules
- Enable permission sharing
- Test delegation flows

### 4. Advanced Permissions

**File**: `docs/SMART_ACCOUNTS_ADVANCED_PERMISSIONS.md`

- Implement ERC-7715
- Enable permission requests
- Manage permission lifecycle
- Test permission flows

---

## Code Examples

### Current: AccountWalletRegistry Usage

```solidity
// Link MetaMask wallet to fiat account
accountWalletRegistry.linkAccountToWallet(
    keccak256("IBAN123"),
    keccak256("0xWalletAddress"),
    keccak256("METAMASK")
);
```

### Proposed: Smart Account Integration

```solidity
// Create smart account and link to fiat account
address smartAccount = smartAccountFactory.createAccount(userAddress);
accountWalletRegistry.linkAccountToWallet(
    keccak256("IBAN123"),
    keccak256(abi.encodePacked(smartAccount)),
    keccak256("METAMASK_SMART_ACCOUNT")
);
```

### Proposed: Delegation Usage

```typescript
// Request delegation from user
const delegation = await smartAccountsKit.requestDelegation({
  target: dAppAddress,
  permissions: ['execute_transactions', 'batch_operations'],
  expiry: Date.now() + 86400000, // 24 hours
});
```

---

## Benefits of Integration

### For Users

- ✅ **Programmable Accounts**: Custom account behavior
- ✅ **Gas Abstraction**: Pay gas in tokens
- ✅ **Batch Operations**: Multiple transactions in one
- ✅ **Permission Sharing**: Share permissions with dApps

### For dApps

- ✅ **Execute on Behalf**: Execute transactions for users
- ✅ **Advanced Permissions**: Fine-grained permission control
- ✅ **Better UX**: Batch operations, gas abstraction
- ✅ **Delegation**: Rule-based permission sharing

### For Payment Rails

- ✅ **Keep Existing System**: RailEscrowVault continues to work
- ✅ **Enhanced Capabilities**: Add smart account features
- ✅ **Better Integration**: Bridge traditional and Web3
- ✅ **Compliance**: Maintain compliance with smart accounts

---

## Implementation Checklist

### Phase 1: Smart Accounts Deployment

- [ ] Review MetaMask Smart Accounts Kit documentation
- [ ] Deploy Smart Accounts contracts to ChainID 138
- [ ] Configure delegation framework
- [ ] Test smart account creation
- [ ] Test delegation flows

### Phase 2: AccountWalletRegistry Integration

- [ ] Extend AccountWalletRegistry interface
- [ ] Add smart account support
- [ ] Update linking functions
- [ ] Test smart account linking
- [ ] Update API documentation

### Phase 3: Advanced Features

- [ ] Implement ERC-7715 Advanced Permissions
- [ ] Add gas abstraction support
- [ ] Enable user operation batching
- [ ] Test all features
- [ ] Create integration guides

---

## Partner Integrations

According to [MetaMask Smart Accounts Kit documentation](https://docs.metamask.io/smart-accounts-kit#partner-integrations), the following partners are integrated:

- **Scaffold-ETH 2**: Smart Accounts extension
- **Viem**: Smart Accounts support
- **Arbitrum**: Network support
- **permissionless.js**: Smart Accounts integration
- **Monad**: Testnet support

**ChainID 138 Integration Opportunity**:
- Submit ChainID 138 for Smart Accounts Kit support
- Create partner integration guide
- Test with existing partners

---

## Conclusion

The Proxmox Smart Vault system (RailEscrowVault, AccountWalletRegistry) serves a **different purpose** than MetaMask Smart Accounts Kit:

- **Smart Vault**: Payment rail settlement and compliance
- **Smart Accounts Kit**: Programmable accounts and dApp integration

**However**, they can be **complementary**:
- Smart Vault handles payment rails
- Smart Accounts Kit handles dApp interactions
- AccountWalletRegistry bridges both systems

**Recommended Action**: Deploy MetaMask Smart Accounts Kit alongside existing Smart Vault system for enhanced capabilities.

---

**Last Updated**: 2026-01-26
