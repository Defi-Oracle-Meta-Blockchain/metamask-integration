# Performance Testing Guide - Smart Accounts

**Date**: 2026-01-26  
**Network**: ChainID 138 (SMOM-DBIS-138)

---

## Overview

This guide explains how to perform performance testing for Smart Accounts Kit integration.

---

## Performance Metrics

### Key Metrics

1. **Smart Account Creation Time**
   - Target: < 5 seconds
   - Measurement: Time from request to account creation

2. **Delegation Request Time**
   - Target: < 10 seconds
   - Measurement: Time from request to approval

3. **User Operation Batch Time**
   - Target: < 15 seconds
   - Measurement: Time from batch creation to execution

4. **Gas Usage**
   - Target: Optimize for batch operations
   - Measurement: Gas per operation

---

## Testing Tools

### 1. Performance Test Script

**File**: `scripts/performance-test.sh`

**Usage**:
```bash
./scripts/performance-test.sh
```

**Tests**:
- Smart account creation performance
- Delegation performance
- Batch operations performance

### 2. Load Testing

**Tools**:
- Apache Bench (ab)
- wrk
- k6
- Artillery

**Example**:
```bash
# Load test smart account creation
ab -n 100 -c 10 https://api.d-bis.org/smart-accounts/create
```

### 3. Gas Benchmarking

**Tool**: Foundry gas reporting

**Usage**:
```bash
forge test --match-path test/smart-accounts/** --gas-report
```

---

## Test Scenarios

### Scenario 1: Smart Account Creation

**Test**: Create 100 smart accounts sequentially

**Metrics**:
- Total time
- Average time per account
- Peak time
- Success rate

**Expected Results**:
- Average: < 5 seconds
- Peak: < 10 seconds
- Success rate: > 99%

### Scenario 2: Delegation Requests

**Test**: Request 50 delegations

**Metrics**:
- Total time
- Average time per delegation
- Success rate

**Expected Results**:
- Average: < 10 seconds
- Success rate: > 95%

### Scenario 3: Batch Operations

**Test**: Execute 100 batch operations

**Metrics**:
- Total time
- Average time per batch
- Gas savings vs individual operations

**Expected Results**:
- Average: < 15 seconds
- Gas savings: > 30%

---

## Performance Optimization

### 1. Gas Optimization

- Use batch operations
- Optimize storage patterns
- Minimize external calls
- Use events instead of storage where possible

### 2. Network Optimization

- Use efficient RPC endpoints
- Implement connection pooling
- Cache frequently accessed data
- Use batch RPC calls

### 3. Caching

- Cache smart account addresses
- Cache delegation status
- Cache permission status
- Invalidate on updates

---

## Monitoring Performance

### Real-time Metrics

```typescript
// Track account creation time
const startTime = Date.now();
const account = await kit.createAccount({ owner: userAddress });
const duration = Date.now() - startTime;

// Log to analytics
analytics.track('account_created', {
  duration,
  gasUsed: receipt.gasUsed,
});
```

### Performance Dashboard

Configure Grafana dashboard with:
- Account creation rate
- Average creation time
- Delegation success rate
- Gas usage trends
- Error rates

---

## Benchmarking

### Baseline Metrics

Before optimization:
- Account creation: ~10 seconds
- Delegation: ~15 seconds
- Batch operations: ~20 seconds

### Target Metrics

After optimization:
- Account creation: < 5 seconds
- Delegation: < 10 seconds
- Batch operations: < 15 seconds

---

## Troubleshooting Performance Issues

### Issue: Slow Account Creation

**Causes**:
- Network latency
- RPC endpoint issues
- Gas price too low

**Solutions**:
- Use faster RPC endpoint
- Increase gas price
- Implement retry logic

### Issue: High Gas Usage

**Causes**:
- Inefficient contract code
- Too many operations
- No batching

**Solutions**:
- Optimize contract code
- Use batch operations
- Cache results

---

## Resources

- [Performance Testing Script](./scripts/performance-test.sh)
- [Monitoring Configuration](./config/monitoring-config.json)
- [Analytics Configuration](./config/analytics-config.json)

---

**Last Updated**: 2026-01-26
