# Smart Accounts Kit Deployment Checklist

**Date**: 2026-01-26  
**Network**: ChainID 138 (SMOM-DBIS-138)

---

## Pre-Deployment Checklist

### Environment Setup

- [ ] Foundry installed and configured
- [ ] Node.js installed (v18+)
- [ ] Environment variables configured (`.env`)
- [ ] RPC endpoint accessible
- [ ] Deployer has sufficient ETH for gas
- [ ] Private key secured and backed up

### Configuration

- [ ] `RPC_URL_138` set in `.env`
- [ ] `PRIVATE_KEY` set in `.env`
- [ ] `SMART_ACCOUNT_FACTORY` address (if deploying)
- [ ] `ENTRY_POINT` address (if deploying)
- [ ] `PAYMASTER` address (optional)

---

## Phase 1: Foundation Deployment

### Install SDK

- [ ] Run `./scripts/install-smart-accounts-sdk.sh`
- [ ] Verify SDK installed correctly
- [ ] Check `node_modules/@metamask/smart-accounts-kit` exists

### Deploy Contracts

- [ ] Deploy EntryPoint contract
  ```bash
  forge script script/smart-accounts/DeploySmartAccountsKit.s.sol \
    --rpc-url $RPC_URL_138 --broadcast
  ```
- [ ] Record EntryPoint address
- [ ] Deploy AccountFactory contract
- [ ] Record AccountFactory address
- [ ] Deploy Paymaster contract (optional)
- [ ] Record Paymaster address

### Update Configuration

- [ ] Update `config/smart-accounts-config.json` with addresses
- [ ] Verify configuration is correct
- [ ] Test configuration loading

---

## Phase 2: AccountWalletRegistry Integration

### Deploy Extended Registry

- [ ] Deploy AccountWalletRegistryExtended
  ```bash
  forge script script/smart-accounts/DeployAccountWalletRegistryExtended.s.sol \
    --rpc-url $RPC_URL_138 --broadcast
  ```
- [ ] Record AccountWalletRegistryExtended address
- [ ] Grant ACCOUNT_MANAGER_ROLE to authorized addresses
- [ ] Verify roles are set correctly

### Integration Testing

- [ ] Test linking EOA wallet
- [ ] Test linking Smart Account
- [ ] Test `isSmartAccount()` function
- [ ] Test `getSmartAccounts()` function
- [ ] Verify events are emitted

---

## Phase 3: Testing

### Unit Tests

- [ ] Test smart account creation
- [ ] Test AccountWalletRegistry linking
- [ ] Test delegation framework
- [ ] Test Advanced Permissions
- [ ] Test user operations batching

### Integration Tests

- [ ] Test Smart account + RailEscrowVault
- [ ] Test Smart account + SettlementOrchestrator
- [ ] Test Delegation + Payment rails
- [ ] Test Advanced Permissions + dApps
- [ ] Test AccountWalletRegistry with both EOA and smart accounts

### End-to-End Tests

- [ ] Test complete payment rail flow with smart account
- [ ] Test complete dApp interaction flow
- [ ] Test hybrid EOA + smart account flow
- [ ] Test delegation expiry and renewal
- [ ] Test permission lifecycle

---

## Phase 4: Security

### Security Audit

- [ ] Audit EntryPoint contract
- [ ] Audit AccountFactory contract
- [ ] Audit Paymaster contract (if deployed)
- [ ] Audit AccountWalletRegistryExtended contract
- [ ] Fix any security issues found

### Access Control

- [ ] Verify role-based access control
- [ ] Test permission checks
- [ ] Verify admin functions are protected
- [ ] Test emergency pause (if applicable)

---

## Phase 5: Production Deployment

### Final Checks

- [ ] All tests passing
- [ ] Security audit complete
- [ ] Documentation complete
- [ ] Configuration verified
- [ ] Monitoring set up

### Deployment

- [ ] Deploy to production network
- [ ] Verify contracts deployed correctly
- [ ] Update production configuration
- [ ] Test production deployment
- [ ] Monitor for issues

### Post-Deployment

- [ ] User acceptance testing
- [ ] Performance testing
- [ ] Load testing
- [ ] Monitor metrics
- [ ] Document deployment addresses

---

## Verification Steps

### Contract Verification

- [ ] Verify EntryPoint on block explorer
- [ ] Verify AccountFactory on block explorer
- [ ] Verify Paymaster on block explorer (if deployed)
- [ ] Verify AccountWalletRegistryExtended on block explorer

### Functionality Verification

- [ ] Create test smart account
- [ ] Link smart account to test account
- [ ] Test delegation request
- [ ] Test permission request
- [ ] Test batch operations

---

## Documentation

### User Documentation

- [ ] Smart Accounts User Guide complete
- [ ] FAQ document complete
- [ ] Troubleshooting guide complete

### Developer Documentation

- [ ] Smart Accounts Developer Guide complete
- [ ] Delegation Usage Guide complete
- [ ] Advanced Permissions Guide complete
- [ ] API documentation complete

### Deployment Documentation

- [ ] Deployment guide complete
- [ ] Configuration guide complete
- [ ] Troubleshooting guide complete

---

## Monitoring and Maintenance

### Monitoring Setup

- [ ] Set up contract monitoring
- [ ] Set up transaction monitoring
- [ ] Set up error alerting
- [ ] Set up performance monitoring

### Maintenance

- [ ] Schedule regular security reviews
- [ ] Plan for upgrades
- [ ] Document maintenance procedures
- [ ] Set up backup procedures

---

## Rollback Plan

### If Issues Occur

- [ ] Document rollback procedure
- [ ] Test rollback procedure
- [ ] Keep EOA support active (backward compatible)
- [ ] Have emergency pause ready (if applicable)

---

## Success Criteria

### Technical

- [ ] All contracts deployed successfully
- [ ] All tests passing
- [ ] Security audit passed
- [ ] Performance meets requirements

### User Experience

- [ ] Users can create smart accounts
- [ ] Users can link smart accounts
- [ ] Delegation works correctly
- [ ] Permissions work correctly

---

**Last Updated**: 2026-01-26
