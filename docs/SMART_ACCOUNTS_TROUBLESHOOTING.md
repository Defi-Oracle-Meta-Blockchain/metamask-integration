# Smart Accounts Troubleshooting Guide

**Date**: 2026-01-26  
**Network**: ChainID 138 (SMOM-DBIS-138)

---

## Common Issues and Solutions

### Smart Account Creation

#### Issue: Cannot Create Smart Account

**Symptoms**:
- Transaction fails
- Error: "Insufficient funds"
- Error: "Contract deployment failed"

**Solutions**:
1. **Check ETH Balance**: Ensure sufficient ETH for gas
   ```bash
   cast balance $USER_ADDRESS --rpc-url $RPC_URL_138
   ```

2. **Check RPC Connection**: Verify RPC endpoint is accessible
   ```bash
   cast block-number --rpc-url $RPC_URL_138
   ```

3. **Check EntryPoint**: Verify EntryPoint is deployed
   ```bash
   cast code $ENTRY_POINT_ADDRESS --rpc-url $RPC_URL_138
   ```

4. **Check AccountFactory**: Verify AccountFactory is deployed
   ```bash
   cast code $ACCOUNT_FACTORY_ADDRESS --rpc-url $RPC_URL_138
   ```

---

#### Issue: Smart Account Creation Takes Too Long

**Symptoms**:
- Transaction pending for extended time
- No confirmation received

**Solutions**:
1. **Check Network**: Verify network is not congested
2. **Increase Gas Price**: Use higher gas price
3. **Check Transaction**: Verify transaction was submitted
   ```bash
   cast tx $TX_HASH --rpc-url $RPC_URL_138
   ```

---

### AccountWalletRegistry Integration

#### Issue: Cannot Link Smart Account

**Symptoms**:
- Error: "AccountWalletRegistryExtended: not a contract"
- Error: "AccountWalletRegistryExtended: zero smartAccount"

**Solutions**:
1. **Verify Smart Account**: Ensure address is a contract
   ```bash
   cast code $SMART_ACCOUNT_ADDRESS --rpc-url $RPC_URL_138
   ```

2. **Check Permissions**: Verify caller has ACCOUNT_MANAGER_ROLE
   ```solidity
   registry.hasRole(registry.ACCOUNT_MANAGER_ROLE(), caller)
   ```

3. **Check Address**: Ensure address is not zero address

---

#### Issue: isSmartAccount() Returns False

**Symptoms**:
- `isSmartAccount()` returns false for valid smart account
- Smart account not detected

**Solutions**:
1. **Verify Link**: Check if smart account was linked
   ```solidity
   registry.isLinked(accountRefId, walletRefId)
   ```

2. **Check Mapping**: Verify `_isSmartAccount` mapping is set
3. **Re-link**: Try linking the smart account again

---

### Delegation Issues

#### Issue: Delegation Request Fails

**Symptoms**:
- Error: "User rejected"
- Error: "Permission denied"

**Solutions**:
1. **Check MetaMask**: Ensure MetaMask is unlocked
2. **Check Network**: Verify connected to ChainID 138
3. **Review Request**: Check delegation request details
4. **Try Again**: Retry after refresh

---

#### Issue: Delegation Not Working

**Symptoms**:
- dApp cannot execute transactions
- Error: "Delegation expired"

**Solutions**:
1. **Check Status**: Verify delegation is active
   ```typescript
   const status = await kit.getDelegationStatus({
     target: dAppAddress,
     account: smartAccountAddress,
   });
   ```

2. **Check Expiry**: Verify delegation hasn't expired
   ```typescript
   if (status.expiry < Date.now()) {
     // Delegation expired, request new one
   }
   ```

3. **Check Permissions**: Verify required permissions are granted
4. **Revoke and Re-grant**: Try revoking and re-granting delegation

---

### Advanced Permissions Issues

#### Issue: Permission Request Denied

**Symptoms**:
- Permission request rejected
- Error: "Permission denied"

**Solutions**:
1. **Check MetaMask**: Ensure MetaMask is unlocked
2. **Review Request**: Check permission details
3. **Check Function**: Verify function selector is correct
4. **Try Again**: Retry after refresh

---

#### Issue: Permission Not Working

**Symptoms**:
- Permission granted but function fails
- Error: "Permission denied"

**Solutions**:
1. **Check Permission**: Verify permission is granted
   ```typescript
   const hasPermission = await kit.hasPermission({
     account: smartAccountAddress,
     target: contractAddress,
     functionSelector: functionSelector,
   });
   ```

2. **Check Function Selector**: Verify selector matches
3. **Check Target**: Verify contract address is correct
4. **Revoke and Re-grant**: Try revoking and re-granting permission

---

### User Operations (Batch) Issues

#### Issue: Batch Operation Fails

**Symptoms**:
- Batch transaction fails
- Error: "User operation failed"

**Solutions**:
1. **Check Operations**: Verify all operations are valid
2. **Check Gas**: Ensure sufficient gas for batch
3. **Check Permissions**: Verify required permissions are granted
4. **Try Individually**: Test operations individually first

---

### Gas Abstraction Issues

#### Issue: Gas Abstraction Not Working

**Symptoms**:
- User still pays gas
- Error: "Paymaster not configured"

**Solutions**:
1. **Check Paymaster**: Verify Paymaster is deployed
   ```bash
   cast code $PAYMASTER_ADDRESS --rpc-url $RPC_URL_138
   ```

2. **Check Configuration**: Verify Paymaster is configured in SDK
   ```typescript
   const kit = new SmartAccountsKit({
     paymasterAddress: '0x...', // Must be set
   });
   ```

3. **Check Funding**: Verify Paymaster has funds
4. **Check Policy**: Verify Paymaster policy allows operation

---

## Debugging Tools

### Check Smart Account

```bash
# Check if address is a contract
cast code $SMART_ACCOUNT_ADDRESS --rpc-url $RPC_URL_138

# Check balance
cast balance $SMART_ACCOUNT_ADDRESS --rpc-url $RPC_URL_138

# Check nonce
cast nonce $SMART_ACCOUNT_ADDRESS --rpc-url $RPC_URL_138
```

### Check Delegation

```typescript
// Check delegation status
const status = await kit.getDelegationStatus({
  target: dAppAddress,
  account: smartAccountAddress,
});

console.log('Active:', status.active);
console.log('Expires:', status.expiry);
console.log('Permissions:', status.permissions);
```

### Check Permissions

```typescript
// Check permission
const hasPermission = await kit.hasPermission({
  account: smartAccountAddress,
  target: contractAddress,
  functionSelector: functionSelector,
});

console.log('Has permission:', hasPermission);
```

---

## Getting Help

### Documentation

- [Smart Accounts User Guide](./SMART_ACCOUNTS_USER_GUIDE.md)
- [Smart Accounts Developer Guide](./SMART_ACCOUNTS_DEVELOPER_GUIDE.md)
- [Delegation Usage Guide](./DELEGATION_USAGE_GUIDE.md)
- [Advanced Permissions Guide](./ADVANCED_PERMISSIONS_GUIDE.md)

### Support Channels

1. **Check Documentation**: Review guides first
2. **Search Issues**: Check for similar issues
3. **Contact Support**: Reach out to support team
4. **Community**: Ask in community forums

---

## Prevention Tips

### Best Practices

1. **Test First**: Test on testnet before mainnet
2. **Check Balances**: Ensure sufficient funds
3. **Verify Contracts**: Check contract addresses
4. **Monitor Expiry**: Track delegation/permission expiry
5. **Review Permissions**: Review before granting

### Monitoring

1. **Transaction History**: Monitor transaction history
2. **Delegation Status**: Check active delegations
3. **Permission Status**: Check granted permissions
4. **Error Logs**: Review error logs regularly

---

**Last Updated**: 2026-01-26
