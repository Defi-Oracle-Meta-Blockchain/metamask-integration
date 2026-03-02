# Smart Accounts FAQ

**Date**: 2026-01-26  
**Network**: ChainID 138 (SMOM-DBIS-138)

---

## General Questions

### Q: What are Smart Accounts?

**A**: Smart Accounts are programmable accounts that enable:
- Delegation (share permissions with dApps)
- Advanced Permissions (fine-grained access control)
- Batch Operations (multiple transactions in one)
- Gas Abstraction (pay gas in tokens)

---

### Q: What's the difference between EOA and Smart Account?

**A**: 
- **EOA** (Externally Owned Account): Standard wallet, no programmable features
- **Smart Account**: Programmable account with delegation and permissions

---

### Q: Can I have both EOA and Smart Account?

**A**: Yes! You can link both to the same fiat account via AccountWalletRegistry.

---

### Q: Are Smart Accounts more secure?

**A**: Smart Accounts offer additional security features:
- Delegation with expiry
- Fine-grained permissions
- Programmable compliance checks
- Multi-signature support

---

### Q: Do I pay more gas with Smart Accounts?

**A**: 
- Initial creation costs more
- Batch operations can save gas overall
- Gas abstraction can eliminate gas costs

---

## Delegation Questions

### Q: What is Delegation?

**A**: Delegation allows dApps to execute transactions on your behalf with time-limited permissions.

---

### Q: Can I revoke delegation?

**A**: Yes, you can revoke delegation anytime through MetaMask.

---

### Q: What happens when delegation expires?

**A**: Delegation becomes inactive and cannot be used. You must grant a new delegation.

---

### Q: Can I extend delegation expiry?

**A**: No, you must revoke and re-grant with new expiry.

---

### Q: Can I have multiple delegations?

**A**: Yes, you can grant multiple delegations to different dApps.

---

## Advanced Permissions Questions

### Q: What are Advanced Permissions?

**A**: Advanced Permissions (ERC-7715) are fine-grained, function-level permissions for Smart Accounts.

---

### Q: What's the difference between Delegation and Advanced Permissions?

**A**: 
- **Delegation**: Broad permission for dApp to execute transactions
- **Advanced Permissions**: Fine-grained, function-level permissions

---

### Q: Do permissions expire?

**A**: Permissions don't expire automatically, but can be revoked anytime.

---

### Q: Can I grant permission for multiple functions?

**A**: Yes, request permission for each function separately.

---

### Q: Can I have multiple permissions?

**A**: Yes, you can grant multiple permissions for different functions.

---

## Payment Rails Questions

### Q: Can I use Smart Accounts for payment rails?

**A**: Yes, if your Smart Account is linked to a fiat account via AccountWalletRegistry.

---

### Q: How do payment rails work with Smart Accounts?

**A**: 
1. Smart Account locks tokens in escrow
2. Settlement orchestrator processes
3. Tokens released after completion

---

### Q: What are the benefits?

**A**: 
- Enhanced security
- Delegation with expiry
- Programmable compliance checks

---

## Technical Questions

### Q: How do I create a Smart Account?

**A**: 
```typescript
const smartAccount = await kit.createAccount({
  owner: userAddress,
});
```

---

### Q: How do I link Smart Account to fiat account?

**A**: Contact your account manager to link your Smart Account address.

---

### Q: How do I check if an address is a Smart Account?

**A**: 
```typescript
const isSmart = await registry.isSmartAccountAddress(address);
```

---

### Q: How do I check delegation status?

**A**: 
```typescript
const status = await kit.getDelegationStatus({
  target: dAppAddress,
  account: smartAccountAddress,
});
```

---

### Q: How do I check permission?

**A**: 
```typescript
const hasPermission = await kit.hasPermission({
  account: smartAccountAddress,
  target: contractAddress,
  functionSelector: functionSelector,
});
```

---

## Troubleshooting Questions

### Q: Smart Account creation fails. What should I do?

**A**: 
1. Check ETH balance for gas
2. Verify RPC connection
3. Check EntryPoint and AccountFactory are deployed
4. Try again after refresh

---

### Q: Delegation not working. What should I do?

**A**: 
1. Check delegation is active
2. Verify expiry hasn't passed
3. Check permissions are correct
4. Try revoking and re-granting

---

### Q: Permission denied. What should I do?

**A**: 
1. Check MetaMask is unlocked
2. Review permission request details
3. Ensure sufficient gas
4. Try again after refresh

---

## Security Questions

### Q: Are Smart Accounts safe?

**A**: Yes, Smart Accounts use the same security model as standard accounts with additional programmable features.

---

### Q: Can someone steal my Smart Account?

**A**: No, Smart Accounts are secured by the same private key as standard accounts.

---

### Q: What if I lose my private key?

**A**: You lose access to your Smart Account, same as with standard accounts. Consider using hardware wallets.

---

### Q: Can I recover my Smart Account?

**A**: No, if you lose your private key, you cannot recover your Smart Account.

---

## Support Questions

### Q: Where can I get help?

**A**: 
1. Check documentation
2. Review troubleshooting guide
3. Contact support team
4. Visit community forums

---

### Q: How do I report a bug?

**A**: Report bugs through support channels or community forums.

---

### Q: Where can I find examples?

**A**: Check the developer guide for code examples.

---

**Last Updated**: 2026-01-26
