# Migration Guide - EOA to Smart Accounts

**Date**: 2026-01-26  
**Network**: ChainID 138 (SMOM-DBIS-138)

---

## Overview

This guide explains how to migrate from EOA (Externally Owned Accounts) to Smart Accounts for existing users.

---

## Migration Scenarios

### Scenario 1: Keep EOA, Add Smart Account

**Use Case**: User wants both EOA and Smart Account

**Steps**:
1. Create Smart Account
2. Link Smart Account to same fiat account
3. Use EOA for payment rails
4. Use Smart Account for dApp interactions

**Benefits**:
- Backward compatible
- Gradual migration
- No disruption

---

### Scenario 2: Full Migration to Smart Account

**Use Case**: User wants to fully migrate to Smart Account

**Steps**:
1. Create Smart Account
2. Transfer assets from EOA to Smart Account
3. Link Smart Account to fiat account
4. Update all references to use Smart Account
5. Deactivate EOA link (optional)

**Benefits**:
- Full Smart Account features
- Enhanced security
- Delegation support

---

## Migration Process

### Step 1: Create Smart Account

```typescript
import { SmartAccountsKit } from '@metamask/smart-accounts-kit';

const kit = new SmartAccountsKit({ ... });

const smartAccount = await kit.createAccount({
  owner: userEOAAddress,
});
```

### Step 2: Link to Fiat Account

```typescript
// Contact account manager to link Smart Account
// Provide: Smart Account address, fiat account reference
```

### Step 3: Transfer Assets (if migrating)

```typescript
// Transfer tokens from EOA to Smart Account
await token.transfer(smartAccountAddress, amount);
```

### Step 4: Update References

- Update dApp configurations
- Update payment rail references
- Update delegation targets

---

## Migration Checklist

### Pre-Migration

- [ ] Review Smart Account features
- [ ] Understand delegation and permissions
- [ ] Backup current configuration
- [ ] Test on testnet (if available)

### Migration

- [ ] Create Smart Account
- [ ] Link to fiat account
- [ ] Transfer assets (if migrating)
- [ ] Update configurations
- [ ] Test functionality

### Post-Migration

- [ ] Verify Smart Account works
- [ ] Test delegation (if needed)
- [ ] Test permissions (if needed)
- [ ] Monitor for issues

---

## Rollback Procedure

### If Issues Occur

1. **Keep EOA Active**: Don't deactivate EOA link
2. **Use EOA**: Switch back to EOA for operations
3. **Investigate**: Identify and fix issues
4. **Retry**: Try migration again after fixes

---

## Best Practices

### 1. Gradual Migration

- Start with Smart Account for new features
- Keep EOA for existing operations
- Gradually migrate operations

### 2. Testing

- Test on testnet first
- Test with small amounts
- Verify all functionality

### 3. Documentation

- Document migration steps
- Keep rollback plan ready
- Monitor for issues

---

## Support

For migration assistance:
1. Review this guide
2. Check troubleshooting guide
3. Contact support team

---

**Last Updated**: 2026-01-26
