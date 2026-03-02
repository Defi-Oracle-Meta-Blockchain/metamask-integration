# Quick Start Deployment Guide - Smart Accounts

**Date**: 2026-01-26  
**Network**: ChainID 138 (SMOM-DBIS-138)

---

## Overview

This guide provides a quick start for deploying Smart Accounts Kit on ChainID 138.

---

## Prerequisites

### Required

- **Foundry**: Installed and configured
- **Node.js**: v18 or higher
- **RPC Access**: Access to ChainID 138 RPC endpoint
- **ETH Balance**: Sufficient ETH for gas fees

### Environment Setup

1. **Set up environment variables** in `smom-dbis-138/.env`:
   ```bash
   RPC_URL_138=https://rpc.d-bis.org
   PRIVATE_KEY=your_private_key_here
   ```

2. **Verify prerequisites**:
   ```bash
   forge --version
   node --version
   ```

---

## Quick Deployment (5 Steps)

### Step 1: Install SDK

```bash
cd metamask-integration
./scripts/install-smart-accounts-sdk.sh
```

### Step 2: Deploy Smart Accounts Kit Contracts

```bash
cd ../smom-dbis-138
forge script script/smart-accounts/DeploySmartAccountsKit.s.sol \
  --rpc-url $RPC_URL_138 \
  --broadcast \
  --verify
```

**Record the deployed addresses**:
- EntryPoint address
- AccountFactory address
- Paymaster address (if deployed)

### Step 3: Update Configuration

```bash
cd ../metamask-integration
./scripts/update-smart-accounts-config.sh --interactive
```

Enter the deployed contract addresses when prompted.

### Step 4: Deploy AccountWalletRegistryExtended

```bash
cd ../smom-dbis-138
# Set environment variables first
export SMART_ACCOUNT_FACTORY=<AccountFactory address>
export ENTRY_POINT=<EntryPoint address>

forge script script/smart-accounts/DeployAccountWalletRegistryExtended.s.sol \
  --rpc-url $RPC_URL_138 \
  --broadcast \
  --verify
```

### Step 5: Verify Deployment

```bash
cd ../metamask-integration
./scripts/verify-deployment.sh
./scripts/health-check.sh
```

---

## Automated Deployment

For a fully automated deployment:

```bash
cd metamask-integration
./scripts/deploy-smart-accounts-complete.sh
```

**Note**: You'll still need to manually update configuration with contract addresses after deployment.

---

## Post-Deployment

### 1. Setup Monitoring

```bash
./scripts/setup-monitoring.sh
```

### 2. Run Tests

```bash
# Unit tests
cd ../smom-dbis-138
forge test --match-path test/smart-accounts/** -vv

# Integration tests
cd ../metamask-integration
npm test
```

### 3. Validate Configuration

```bash
./scripts/validate-config.sh
```

---

## Verification Checklist

- [ ] SDK installed
- [ ] Contracts deployed
- [ ] Configuration updated
- [ ] AccountWalletRegistryExtended deployed
- [ ] Health check passed
- [ ] Tests passing
- [ ] Monitoring configured

---

## Troubleshooting

### Common Issues

**Issue**: RPC connection failed
- **Solution**: Verify `RPC_URL_138` is correct and accessible

**Issue**: Insufficient gas
- **Solution**: Ensure deployer address has sufficient ETH

**Issue**: Contract verification failed
- **Solution**: Check block explorer API key and network connectivity

**Issue**: Configuration validation failed
- **Solution**: Run `./scripts/validate-config.sh` to identify issues

---

## Next Steps

1. **Security Audit**: Review [Security Audit Preparation](./SECURITY_AUDIT_PREPARATION.md)
2. **Testing**: Follow [Testing Guide](./TESTING_GUIDE.md)
3. **Monitoring**: Setup monitoring per [Infrastructure Setup](./INFRASTRUCTURE_SETUP.md)
4. **Documentation**: Review all guides in `docs/` directory

---

## Resources

- [Deployment Checklist](../DEPLOYMENT_CHECKLIST.md)
- [Developer Guide](./SMART_ACCOUNTS_DEVELOPER_GUIDE.md)
- [Troubleshooting Guide](./SMART_ACCOUNTS_TROUBLESHOOTING.md)
- [API Reference](./SMART_ACCOUNTS_API_REFERENCE.md)

---

**Last Updated**: 2026-01-26
