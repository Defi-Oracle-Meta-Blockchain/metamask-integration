# Infrastructure Setup Guide - Smart Accounts

**Date**: 2026-01-26  
**Network**: ChainID 138 (SMOM-DBIS-138)

---

## Overview

This guide explains how to set up infrastructure for Smart Accounts Kit integration.

---

## Monitoring Setup

### 1. Prometheus Configuration

**File**: `config/monitoring-config.json`

**Setup**:
```bash
./scripts/setup-monitoring.sh
```

**Metrics**:
- Account creation rate
- Delegation requests
- Permission requests
- User operations
- Gas usage

### 2. Grafana Dashboards

**Create Dashboard**:
1. Import `config/monitoring-config.json`
2. Configure data source (Prometheus)
3. Create panels for each metric

**Panels**:
- Account creation rate (line chart)
- Delegation success rate (gauge)
- Gas usage (bar chart)
- Error rate (line chart)

---

## Alerting Setup

### Alert Rules

**High Gas Usage**:
- Threshold: > 500,000 gas
- Severity: Warning
- Action: Notify team

**Failed Operations**:
- Threshold: > 10 failures in 5 minutes
- Severity: Critical
- Action: Page on-call

**Delegation Expiry**:
- Threshold: Expiring in 7 days
- Severity: Info
- Action: Email notification

---

## Analytics Setup

### 1. Analytics Configuration

**File**: `config/analytics-config.json`

**Events Tracked**:
- Account creations
- Delegation requests
- Permission grants
- User operations
- Gas usage

### 2. Event Tracking

```typescript
// Track account creation
analytics.track('account_created', {
  accountAddress: account.address,
  owner: userAddress,
  timestamp: Date.now(),
});

// Track delegation
analytics.track('delegation_granted', {
  account: smartAccountAddress,
  target: dAppAddress,
  expiry: expiryTime,
});
```

---

## Backup and Recovery

### 1. Backup Setup

**Script**: `scripts/setup-backup-recovery.sh`

**Run**:
```bash
./scripts/setup-backup-recovery.sh
```

**Backup Schedule**:
- Daily backups of configuration
- Weekly backups of state
- Monthly full backups

### 2. Recovery Procedures

**Configuration Recovery**:
```bash
./backups/recover-smart-accounts-config.sh <timestamp>
```

**State Recovery**:
- Restore from blockchain (immutable)
- Re-sync from events
- Rebuild indexes

---

## CI/CD Setup

### GitHub Actions

**Workflow**: `.github/workflows/smart-accounts-ci.yml`

**Jobs**:
- Test contracts
- Test integration
- Lint contracts
- Security scan
- Verify deployment

**Run**:
- On push to main/develop
- On pull requests
- Manual trigger

---

## Security Setup

### 1. Access Control

- Role-based access control
- Multi-signature for admin functions
- Timelock for critical updates

### 2. Monitoring

- Security event monitoring
- Anomaly detection
- Alert on suspicious activity

### 3. Audit Logging

- Log all admin actions
- Log all configuration changes
- Log all security events

---

## Performance Setup

### 1. Performance Monitoring

- Track response times
- Monitor gas usage
- Track success rates

### 2. Load Testing

**Script**: `scripts/performance-test.sh`

**Run**:
```bash
./scripts/performance-test.sh
```

**Metrics**:
- Account creation time
- Delegation time
- Batch operation time

---

## Documentation

### Setup Guides

- [Monitoring Setup](./scripts/setup-monitoring.sh)
- [Backup Setup](./scripts/setup-backup-recovery.sh)
- [Performance Testing](./docs/PERFORMANCE_TESTING_GUIDE.md)

### Configuration Files

- `config/monitoring-config.json`
- `config/analytics-config.json`
- `config/smart-accounts-config.json`

---

**Last Updated**: 2026-01-26
