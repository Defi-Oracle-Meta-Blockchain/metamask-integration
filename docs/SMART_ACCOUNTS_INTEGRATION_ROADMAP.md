# Smart Accounts Kit Integration Roadmap

**Date**: 2026-01-26  
**Reference**: [MetaMask Smart Accounts Kit](https://docs.metamask.io/smart-accounts-kit#partner-integrations)

---

## Overview

This roadmap outlines the integration of MetaMask Smart Accounts Kit with the existing Proxmox Smart Vault System.

---

## Current State Analysis

### Existing System

✅ **RailEscrowVault**: Payment rail escrow system  
✅ **AccountWalletRegistry**: Fiat account to wallet mapping  
✅ **SettlementOrchestrator**: Payment settlement coordination  
✅ **Compliance Integration**: Compliance and policy enforcement  

### Missing Features

❌ **Smart Accounts**: No programmable accounts  
❌ **Delegation**: No delegation framework  
❌ **Advanced Permissions**: No ERC-7715 support  
❌ **User Operations**: No batch transaction support  
❌ **Gas Abstraction**: No gas abstraction  

---

## Integration Phases

### Phase 1: Foundation (Weeks 1-2)

**Goal**: Deploy Smart Accounts Kit infrastructure

**Tasks**:
1. ✅ Review Smart Accounts Kit documentation
2. ✅ Create deployment scripts
3. ✅ Deploy EntryPoint contract
4. ✅ Deploy AccountFactory contract
5. ✅ Deploy Paymaster contract (optional)
6. ✅ Configure for ChainID 138
7. ✅ Test smart account creation

**Deliverables**:
- Smart Accounts contracts deployed
- Deployment scripts ready
- Basic smart account creation working

---

### Phase 2: AccountWalletRegistry Integration (Weeks 3-4)

**Goal**: Integrate Smart Accounts with existing AccountWalletRegistry

**Tasks**:
1. ✅ Extend AccountWalletRegistry interface
2. ✅ Add smart account creation on link
3. ✅ Support both EOA and smart accounts
4. ✅ Update API documentation
5. ✅ Test integration

**Deliverables**:
- AccountWalletRegistry supports smart accounts
- Smart accounts auto-created on link
- Both EOA and smart accounts supported

---

### Phase 3: Delegation Framework (Weeks 5-6)

**Goal**: Implement delegation for payment rails and dApps

**Tasks**:
1. ✅ Implement delegation framework
2. ✅ Create delegation rules
3. ✅ Enable permission sharing
4. ✅ Test delegation flows
5. ✅ Create delegation examples

**Deliverables**:
- Delegation framework implemented
- Delegation rules configured
- Delegation examples created

---

### Phase 4: Advanced Permissions (Weeks 7-8)

**Goal**: Implement ERC-7715 Advanced Permissions

**Tasks**:
1. ✅ Implement ERC-7715 standard
2. ✅ Enable permission requests
3. ✅ Manage permission lifecycle
4. ✅ Test permission flows
5. ✅ Create permission examples

**Deliverables**:
- ERC-7715 implemented
- Permission requests working
- Permission examples created

---

### Phase 5: Production Deployment (Weeks 9-10)

**Goal**: Deploy to production and test

**Tasks**:
1. ✅ Security audit
2. ✅ Production deployment
3. ✅ Integration testing
4. ✅ User acceptance testing
5. ✅ Documentation completion

**Deliverables**:
- Production deployment complete
- All features tested
- Documentation complete

---

## Integration Architecture

```
┌─────────────────────────────────────────────────────────┐
│              AccountWalletRegistry                       │
│  (Extended to support Smart Accounts)                   │
└───────────────┬─────────────────────────────────────────┘
                │
                ├──► EOA Wallet
                │    └──► RailEscrowVault (Payment Rails)
                │
                └──► Smart Account
                     ├──► Delegation Framework
                     ├──► Advanced Permissions (ERC-7715)
                     ├──► User Operations (Batch)
                     └──► Gas Abstraction
```

---

## Use Cases

### Use Case 1: Payment Rails with Smart Accounts

**Scenario**: User wants to use smart account for payment rail operations

**Flow**:
1. Create smart account
2. Link to fiat account via AccountWalletRegistry
3. Delegate payment operations to SettlementOrchestrator
4. Use smart account for escrow operations

**Benefits**:
- Enhanced security
- Delegation with expiry
- Programmable compliance checks

### Use Case 2: dApp Integration with Smart Accounts

**Scenario**: dApp wants to execute transactions on behalf of user

**Flow**:
1. User creates smart account
2. dApp requests Advanced Permissions (ERC-7715)
3. User approves permissions
4. dApp executes transactions on behalf of user

**Benefits**:
- Better UX
- Gas abstraction
- Batch operations

### Use Case 3: Hybrid Approach

**Scenario**: User has both EOA and smart account

**Flow**:
1. Link EOA to fiat account (for payment rails)
2. Link smart account to same fiat account
3. Use EOA for payment rails
4. Use smart account for dApp interactions

**Benefits**:
- Flexibility
- Best of both worlds
- Backward compatible

---

## Technical Implementation

### 1. Smart Account Creation

```typescript
import { SmartAccountsKit } from '@metamask/smart-accounts-kit';

const kit = new SmartAccountsKit({
  chainId: 138,
  rpcUrl: 'https://rpc.d-bis.org',
  entryPointAddress: '0x...',
  accountFactoryAddress: '0x...',
});

const smartAccount = await kit.createAccount({
  owner: userAddress,
});
```

### 2. AccountWalletRegistry Extension

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
```

### 3. Delegation for Payment Rails

```typescript
const delegation = await kit.requestDelegation({
  target: settlementOrchestratorAddress,
  permissions: ['lock_escrow', 'release_escrow'],
  expiry: Date.now() + 86400000,
});
```

---

## Testing Plan

### Unit Tests

- [ ] Smart account creation
- [ ] AccountWalletRegistry linking
- [ ] Delegation framework
- [ ] Advanced Permissions
- [ ] User operations batching

### Integration Tests

- [ ] Smart account + RailEscrowVault
- [ ] Smart account + SettlementOrchestrator
- [ ] Delegation + Payment rails
- [ ] Advanced Permissions + dApps

### End-to-End Tests

- [ ] Complete payment rail flow with smart account
- [ ] Complete dApp interaction flow
- [ ] Hybrid EOA + smart account flow

---

## Success Metrics

### Technical Metrics

- ✅ Smart account creation time < 5 seconds
- ✅ Delegation approval time < 10 seconds
- ✅ User operation batch success rate > 99%
- ✅ Gas savings > 30% (via batching)

### User Experience Metrics

- ✅ User satisfaction > 80%
- ✅ Adoption rate > 50% (of eligible users)
- ✅ Error rate < 1%
- ✅ Support tickets < 5% of transactions

---

## Risk Mitigation

### Technical Risks

1. **Smart Account Deployment Issues**
   - Mitigation: Thorough testing before production
   - Rollback plan: Keep EOA support active

2. **Integration Complexity**
   - Mitigation: Phased rollout
   - Rollback plan: Feature flags

3. **Gas Costs**
   - Mitigation: Paymaster for gas abstraction
   - Rollback plan: Optimize contracts

### Business Risks

1. **User Adoption**
   - Mitigation: Clear documentation and examples
   - Rollback plan: Maintain EOA support

2. **Compliance Issues**
   - Mitigation: Review with compliance team
   - Rollback plan: Compliance checks in smart accounts

---

## Timeline Summary

| Phase | Duration | Status |
|-------|----------|--------|
| Phase 1: Foundation | 2 weeks | ⏳ Pending |
| Phase 2: AccountWalletRegistry | 2 weeks | ⏳ Pending |
| Phase 3: Delegation | 2 weeks | ⏳ Pending |
| Phase 4: Advanced Permissions | 2 weeks | ⏳ Pending |
| Phase 5: Production | 2 weeks | ⏳ Pending |
| **Total** | **10 weeks** | ⏳ Pending |

---

## Dependencies

### External Dependencies

- ✅ MetaMask Smart Accounts Kit SDK
- ✅ ChainID 138 network support
- ✅ RPC endpoint availability
- ✅ Gas for deployment

### Internal Dependencies

- ✅ AccountWalletRegistry contract
- ✅ RailEscrowVault contract
- ✅ SettlementOrchestrator contract
- ✅ Compliance and policy systems

---

## Next Steps

1. **Review Roadmap**: Get stakeholder approval
2. **Start Phase 1**: Deploy Smart Accounts Kit
3. **Test Integration**: Test with existing systems
4. **Iterate**: Refine based on feedback
5. **Deploy**: Deploy to production

---

**Last Updated**: 2026-01-26
