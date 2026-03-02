# Smart Accounts Kit Deployment - Important Note

**Date**: 2026-01-26  
**Status**: ⚠️ **Contract Sources Required**

---

## Important Deployment Note

MetaMask Smart Accounts Kit uses **ERC-4337 standard contracts** that need to be deployed:

1. **EntryPoint Contract** (ERC-4337 standard)
2. **AccountFactory Contract** (MetaMask Smart Accounts Kit)
3. **Paymaster Contract** (Optional, for gas abstraction)

---

## Contract Sources

### Option 1: MetaMask Smart Accounts Kit Package

The contracts may be available in the `@metamask/smart-accounts-kit` package:

```bash
npm install @metamask/smart-accounts-kit
# Check for contract artifacts in node_modules/@metamask/smart-accounts-kit
```

### Option 2: Standard ERC-4337 Implementations

Use standard ERC-4337 implementations:

- **OpenZeppelin**: ERC-4337 contracts
- **Alchemy**: Account Abstraction SDK
- **Stackup**: ERC-4337 implementations
- **Pimlico**: ERC-4337 contracts

### Option 3: Use Existing Deployments

If EntryPoint and AccountFactory are already deployed on ChainID 138, use those addresses.

---

## Deployment Steps

### Step 1: Obtain Contract Sources

1. Check `@metamask/smart-accounts-kit` package for contracts
2. Or use standard ERC-4337 implementations
3. Or verify if contracts are already deployed

### Step 2: Deploy Contracts

Once contract sources are available:

```bash
# Deploy EntryPoint
forge script script/smart-accounts/DeployEntryPoint.s.sol \
  --rpc-url $RPC_URL_138 --broadcast

# Deploy AccountFactory
forge script script/smart-accounts/DeployAccountFactory.s.sol \
  --rpc-url $RPC_URL_138 --broadcast

# Deploy Paymaster (optional)
forge script script/smart-accounts/DeployPaymaster.s.sol \
  --rpc-url $RPC_URL_138 --broadcast
```

### Step 3: Update Configuration

```bash
# Update .env
echo "ENTRY_POINT=<deployed-address>" >> smom-dbis-138/.env
echo "SMART_ACCOUNT_FACTORY=<deployed-address>" >> smom-dbis-138/.env
echo "PAYMASTER=<deployed-address>" >> smom-dbis-138/.env  # optional

# Update config
cd metamask-integration
./scripts/update-smart-accounts-config.sh --interactive
```

### Step 4: Deploy AccountWalletRegistryExtended

```bash
cd smom-dbis-138
forge script script/smart-accounts/DeployAccountWalletRegistryExtended.s.sol \
  --rpc-url $RPC_URL_138 --broadcast
```

---

## Current Status

✅ **Deployment script created**: `script/smart-accounts/DeploySmartAccountsKit.s.sol`  
⚠️ **Contract sources needed**: EntryPoint and AccountFactory implementations  
✅ **AccountWalletRegistryExtended ready**: Can be deployed once factory/entry point addresses are set

---

## Next Steps

1. **Obtain contract sources** from MetaMask Smart Accounts Kit or ERC-4337 implementations
2. **Create deployment scripts** for EntryPoint and AccountFactory
3. **Deploy contracts** to ChainID 138
4. **Update configuration** with deployed addresses
5. **Deploy AccountWalletRegistryExtended**

---

**Last Updated**: 2026-01-26
