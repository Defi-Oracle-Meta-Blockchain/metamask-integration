# Executing Network-Dependent Tasks

**Date**: 2026-01-26  
**Purpose**: Guide for executing all 22 network-dependent tasks

---

## Overview

This guide provides step-by-step instructions for executing all network-dependent tasks once network access is available.

**Total Network-Dependent Tasks**: **22**

---

## Prerequisites

### Required Infrastructure

1. **Network Access**:
   - RPC endpoint for ChainID 138 accessible
   - Block explorer access (https://explorer.d-bis.org)
   - Network connectivity verified

2. **Deployer Wallet**:
   - Wallet with sufficient ETH for gas fees
   - Private key secured in `.env` file
   - Backup of private key stored safely

3. **Environment Setup**:
   - Foundry installed (`forge --version`)
   - Node.js v18+ installed (`node --version`)
   - Environment variables configured in `smom-dbis-138/.env`

### Environment Variables

Ensure these are set in `smom-dbis-138/.env`:

```bash
RPC_URL_138=https://rpc.d-bis.org
PRIVATE_KEY=your_private_key_here
SMART_ACCOUNT_FACTORY=0x...  # Set after deployment
ENTRY_POINT=0x...            # Set after deployment
```

---

## Execution Phases

### Phase 1: Contract Deployment (4 tasks)

#### Task 1.1: Deploy EntryPoint Contract

```bash
cd smom-dbis-138
forge script script/smart-accounts/DeploySmartAccountsKit.s.sol \
  --rpc-url $RPC_URL_138 \
  --broadcast \
  --verify \
  -vvv
```

**Record**: EntryPoint contract address

#### Task 1.2: Deploy AccountFactory Contract

```bash
# Same command as above (deploys both EntryPoint and AccountFactory)
# Record AccountFactory address from output
```

**Record**: AccountFactory contract address

#### Task 1.3: Deploy Paymaster Contract (Optional)

```bash
# If deploying Paymaster, update deployment script to include it
# Or deploy separately if needed
```

**Record**: Paymaster contract address (if deployed)

#### Task 1.4: Update Configuration

```bash
cd ../metamask-integration
./scripts/update-smart-accounts-config.sh --interactive
```

Enter the deployed contract addresses when prompted.

#### Task 1.5: Deploy AccountWalletRegistryExtended

```bash
cd ../smom-dbis-138
# Set environment variables first
export SMART_ACCOUNT_FACTORY=<AccountFactory address>
export ENTRY_POINT=<EntryPoint address>

forge script script/smart-accounts/DeployAccountWalletRegistryExtended.s.sol \
  --rpc-url $RPC_URL_138 \
  --broadcast \
  --verify \
  -vvv
```

**Record**: AccountWalletRegistryExtended contract address

---

### Phase 2: Unit Tests (5 tasks)

#### Task 2.1: Test Smart Account Creation

```bash
cd smom-dbis-138
forge test --match-path "test/smart-accounts/**" \
  --match-test "test.*[Cc]reate.*[Aa]ccount" \
  -vv \
  --rpc-url $RPC_URL_138
```

#### Task 2.2: Test AccountWalletRegistry Linking

```bash
forge test --match-path "test/smart-accounts/**" \
  --match-test "test.*[Ll]ink" \
  -vv \
  --rpc-url $RPC_URL_138
```

#### Task 2.3: Test Delegation Framework

```bash
forge test --match-path "test/smart-accounts/**" \
  --match-test "test.*[Dd]elegation" \
  -vv \
  --rpc-url $RPC_URL_138
```

#### Task 2.4: Test Advanced Permissions

```bash
forge test --match-path "test/smart-accounts/**" \
  --match-test "test.*[Pp]ermission" \
  -vv \
  --rpc-url $RPC_URL_138
```

#### Task 2.5: Test User Operations Batching

```bash
forge test --match-path "test/smart-accounts/**" \
  --match-test "test.*[Bb]atch" \
  -vv \
  --rpc-url $RPC_URL_138
```

**Or run all unit tests at once**:

```bash
forge test --match-path "test/smart-accounts/**" -vv --rpc-url $RPC_URL_138
```

---

### Phase 3: Integration Tests (5 tasks)

#### Task 3.1: Test Smart Account + RailEscrowVault

```bash
cd metamask-integration
npm test -- --testNamePattern="RailEscrowVault"
```

#### Task 3.2: Test Smart Account + SettlementOrchestrator

```bash
npm test -- --testNamePattern="SettlementOrchestrator"
```

#### Task 3.3: Test Delegation + Payment Rails

```bash
npm test -- --testNamePattern="Payment.*Rail"
```

#### Task 3.4: Test Advanced Permissions + dApps

```bash
npm test -- --testNamePattern="dApp.*Permission"
```

#### Task 3.5: Test AccountWalletRegistry with EOA and Smart Accounts

```bash
npm test -- --testNamePattern="AccountWalletRegistry"
```

**Or run all integration tests at once**:

```bash
npm test
```

---

### Phase 4: End-to-End Tests (3 tasks)

#### Task 4.1: Test Complete Payment Rail Flow

```bash
npm run test:e2e -- --testNamePattern="Payment.*Rail.*Flow"
```

#### Task 4.2: Test Complete dApp Interaction Flow

```bash
npm run test:e2e -- --testNamePattern="dApp.*Flow"
```

#### Task 4.3: Test Hybrid EOA + Smart Account Flow

```bash
npm run test:e2e -- --testNamePattern="Hybrid.*Flow"
```

**Or run all E2E tests at once**:

```bash
npm run test:e2e
```

---

### Phase 5: Security Audit (1 task)

#### Task 5.1: Execute Security Audit

**This requires engaging a security audit firm.**

1. **Select Audit Firm**:
   - Trail of Bits
   - OpenZeppelin
   - Consensys Diligence
   - Other reputable firms

2. **Prepare Audit Package**:
   - Contract source code
   - Test suite
   - Documentation
   - Deployment addresses

3. **Engage Firm**:
   - Contact firm
   - Agree on scope and timeline
   - Provide audit package

4. **Review Findings**:
   - Review audit report
   - Fix identified issues
   - Re-audit if necessary

**See**: [Security Audit Preparation](./SECURITY_AUDIT_PREPARATION.md)

---

### Phase 6: Production Deployment (1 task)

#### Task 6.1: Deploy to Production Network

**Prerequisites**:
- All tests passing
- Security audit complete
- Production network access
- Production deployer wallet

```bash
cd metamask-integration
./scripts/deploy-smart-accounts-complete.sh
```

**Or manually**:

```bash
cd smom-dbis-138
forge script script/smart-accounts/DeploySmartAccountsKit.s.sol \
  --rpc-url $PRODUCTION_RPC_URL \
  --broadcast \
  --verify \
  -vvv
```

---

### Phase 7: User Acceptance Testing (1 task)

#### Task 7.1: Execute User Acceptance Testing

**Process**:

1. **Recruit Test Users**:
   - Identify target users
   - Provide test accounts
   - Set up communication channel

2. **Define Test Scenarios**:
   - Create Smart Account
   - Link to fiat account
   - Request delegation
   - Use in dApp
   - Test payment rails

3. **Collect Feedback**:
   - User surveys
   - Issue tracking
   - Feedback sessions

4. **Document Issues**:
   - Bug reports
   - UX improvements
   - Feature requests

5. **Fix and Iterate**:
   - Address critical issues
   - Implement improvements
   - Re-test if needed

---

### Phase 8: Performance Testing (1 task)

#### Task 8.1: Execute Performance Testing on Live Network

```bash
cd metamask-integration
./scripts/performance-test.sh
```

**Metrics to Track**:
- Account creation time
- Delegation request time
- Transaction throughput
- Gas usage
- Network latency

**See**: [Performance Testing Guide](./PERFORMANCE_TESTING_GUIDE.md)

---

### Phase 9: Outreach (1 task)

#### Task 9.1: Create Video Tutorials

**Requirements**:
- Screen recording software
- Video editing tools
- Hosting platform (YouTube, etc.)

**Content Ideas**:
- Smart Account creation tutorial
- Delegation setup guide
- dApp integration walkthrough
- Payment rail integration demo

---

## Automated Execution

### Using the Execution Script

```bash
cd metamask-integration

# Deploy all contracts
./scripts/execute-network-tasks.sh deploy

# Run all tests
./scripts/execute-network-tasks.sh test

# Verify deployment
./scripts/execute-network-tasks.sh verify

# Execute everything
./scripts/execute-network-tasks.sh all
```

---

## Verification Checklist

After completing tasks, verify:

- [ ] All contracts deployed successfully
- [ ] Contract addresses recorded
- [ ] Configuration updated
- [ ] All unit tests passing
- [ ] All integration tests passing
- [ ] All E2E tests passing
- [ ] Security audit complete
- [ ] Production deployment successful
- [ ] UAT feedback collected
- [ ] Performance metrics documented

---

## Troubleshooting

### Common Issues

**Issue**: RPC connection failed
- **Solution**: Verify `RPC_URL_138` is correct and accessible

**Issue**: Insufficient gas
- **Solution**: Ensure deployer wallet has sufficient ETH

**Issue**: Contract verification failed
- **Solution**: Check block explorer API key and network connectivity

**Issue**: Tests failing
- **Solution**: Verify contracts are deployed and addresses are correct

---

## Resources

- [Deployment Checklist](../DEPLOYMENT_CHECKLIST.md)
- [Quick Start Deployment](./QUICK_START_DEPLOYMENT.md)
- [Network-Dependent Tasks List](../NETWORK_DEPENDENT_TASKS.md)
- [Security Audit Preparation](./SECURITY_AUDIT_PREPARATION.md)
- [Performance Testing Guide](./PERFORMANCE_TESTING_GUIDE.md)

---

**Last Updated**: 2026-01-26
