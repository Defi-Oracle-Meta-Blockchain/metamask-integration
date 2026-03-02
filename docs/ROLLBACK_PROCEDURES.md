# Rollback Procedures - Smart Accounts

**Date**: 2026-01-26  
**Network**: ChainID 138 (SMOM-DBIS-138)

---

## Overview

This guide explains rollback procedures for Smart Accounts deployments and upgrades.

---

## Rollback Scenarios

### Scenario 1: Contract Deployment Issues

**Symptoms**:
- Contracts deployed incorrectly
- Functionality not working
- Security concerns

**Rollback**:
1. **Pause New Contracts**: Pause affected contracts if possible
2. **Revert to Previous**: Use previous contract versions
3. **Update Configuration**: Update config to point to previous contracts
4. **Verify**: Test that rollback works
5. **Investigate**: Identify and fix issues

---

### Scenario 2: Configuration Issues

**Symptoms**:
- Configuration errors
- Wrong addresses
- Incorrect settings

**Rollback**:
1. **Restore Backup**: Restore previous configuration
   ```bash
   ./backups/recover-smart-accounts-config.sh <timestamp>
   ```
2. **Restart Services**: Restart affected services
3. **Verify**: Test functionality
4. **Fix**: Correct configuration issues

---

### Scenario 3: SDK Upgrade Issues

**Symptoms**:
- SDK version incompatible
- Breaking changes
- Functionality broken

**Rollback**:
1. **Downgrade SDK**: Install previous version
   ```bash
   npm install @metamask/smart-accounts-kit@<previous-version>
   ```
2. **Update Code**: Revert code changes if needed
3. **Test**: Verify functionality
4. **Fix**: Address compatibility issues

---

## Rollback Checklist

### Pre-Rollback

- [ ] Identify issue
- [ ] Assess impact
- [ ] Locate backup/previous version
- [ ] Prepare rollback plan
- [ ] Notify team

### Rollback

- [ ] Pause affected systems
- [ ] Restore previous version
- [ ] Update configuration
- [ ] Restart services
- [ ] Verify functionality

### Post-Rollback

- [ ] Monitor for issues
- [ ] Verify all features work
- [ ] Document rollback
- [ ] Investigate root cause
- [ ] Plan fix

---

## Backup Locations

### Configuration Backups

**Location**: `backups/`

**Files**:
- `smart-accounts-config_<timestamp>.json`
- `monitoring-config_<timestamp>.json`

**Restore**:
```bash
./backups/recover-smart-accounts-config.sh <timestamp>
```

### Contract Backups

**Location**: Block explorer (immutable)

**Information**:
- Previous contract addresses
- Previous deployment transactions
- Previous contract code

---

## Emergency Procedures

### Critical Issues

**Immediate Actions**:
1. **Pause Contracts**: Pause if pause function available
2. **Disable Features**: Disable affected features
3. **Notify Users**: Communicate issue
4. **Investigate**: Identify root cause
5. **Fix**: Implement fix
6. **Test**: Test fix thoroughly
7. **Deploy**: Deploy fix

### Communication

- Notify stakeholders immediately
- Provide status updates
- Document all actions
- Post-mortem after resolution

---

## Prevention

### Best Practices

1. **Test Thoroughly**: Test before deployment
2. **Staged Rollout**: Deploy gradually
3. **Monitor Closely**: Watch for issues
4. **Keep Backups**: Regular backups
5. **Document Changes**: Document all changes

### Testing

- Test on testnet first
- Test with small user group
- Monitor metrics
- Watch for errors

---

## Resources

- [Deployment Checklist](./DEPLOYMENT_CHECKLIST.md)
- [Troubleshooting Guide](./SMART_ACCOUNTS_TROUBLESHOOTING.md)
- [Incident Response](./INCIDENT_RESPONSE.md)

---

**Last Updated**: 2026-01-26
