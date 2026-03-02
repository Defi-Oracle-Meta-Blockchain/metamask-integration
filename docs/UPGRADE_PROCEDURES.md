# Upgrade Procedures - Smart Accounts

**Date**: 2026-01-26  
**Network**: ChainID 138 (SMOM-DBIS-138)

---

## Overview

This guide explains upgrade procedures for Smart Accounts contracts and configuration.

---

## Contract Upgrades

### AccountWalletRegistryExtended

**Upgrade Type**: Proxy pattern (if using upgradeable proxy)

**Procedure**:
1. Deploy new implementation
2. Propose upgrade via governance
3. Wait for approval
4. Execute upgrade
5. Verify functionality

**Rollback**:
- Keep previous implementation
- Can rollback if issues occur

---

## Configuration Upgrades

### Smart Accounts Kit SDK

**Upgrade Steps**:
1. Update package.json
2. Run `npm install`
3. Update configuration if needed
4. Test new version
5. Deploy to production

**Version Compatibility**:
- Check SDK changelog
- Review breaking changes
- Update code if needed

---

## Feature Upgrades

### Adding New Features

**Process**:
1. Deploy new contracts
2. Update configuration
3. Update documentation
4. Test thoroughly
5. Deploy to production

### Enabling Features

**Example**: Enable gas abstraction

1. Deploy Paymaster contract
2. Update configuration
3. Update SDK configuration
4. Test gas abstraction
5. Enable for users

---

## Upgrade Checklist

### Pre-Upgrade

- [ ] Review upgrade notes
- [ ] Backup current configuration
- [ ] Test on testnet
- [ ] Prepare rollback plan

### Upgrade

- [ ] Deploy new contracts
- [ ] Update configuration
- [ ] Update SDK
- [ ] Test functionality
- [ ] Monitor for issues

### Post-Upgrade

- [ ] Verify all features work
- [ ] Monitor metrics
- [ ] Check error logs
- [ ] Update documentation

---

## Rollback Procedures

### Contract Rollback

1. Identify issue
2. Pause new implementation
3. Rollback to previous version
4. Verify rollback success
5. Investigate issue

### Configuration Rollback

1. Restore previous configuration
2. Restart services
3. Verify functionality
4. Investigate issue

---

## Best Practices

### 1. Staged Rollout

- Deploy to testnet first
- Deploy to staging
- Deploy to production gradually

### 2. Monitoring

- Monitor during upgrade
- Watch for errors
- Track metrics

### 3. Communication

- Notify users of upgrades
- Document changes
- Provide support

---

## Resources

- [Deployment Checklist](./DEPLOYMENT_CHECKLIST.md)
- [Troubleshooting Guide](./SMART_ACCOUNTS_TROUBLESHOOTING.md)

---

**Last Updated**: 2026-01-26
