# Smart Accounts Testing Guide

**Date**: 2026-01-26  
**Network**: ChainID 138 (SMOM-DBIS-138)

---

## Overview

This guide explains how to test Smart Accounts Kit integration on ChainID 138.

---

## Test Structure

### Unit Tests (Foundry)

Located in `test/smart-accounts/`:

```
test/smart-accounts/
├── AccountWalletRegistryExtendedTest.t.sol  # Extended registry tests
└── (Additional test files to be created)
```

### Integration Tests (TypeScript/JavaScript)

Located in `test/`:

```
test/
└── smart-accounts-integration.test.ts  # Integration tests
```

---

## Running Tests

### Unit Tests (Foundry)

```bash
# Run all Smart Accounts tests
forge test --match-path test/smart-accounts/** -vv

# Run specific test file
forge test --match-path test/smart-accounts/AccountWalletRegistryExtendedTest.t.sol -vv

# Run with gas reporting
forge test --match-path test/smart-accounts/** --gas-report

# Run with coverage
forge coverage --match-path test/smart-accounts/**
```

### Integration Tests

```bash
# Install dependencies
npm install

# Run integration tests
npm test

# Run with coverage
npm test -- --coverage
```

---

## Test Categories

### 1. Unit Tests

**AccountWalletRegistryExtended**:
- Link smart account
- Check if smart account
- Support both EOA and smart accounts
- Role-based access control
- Factory and EntryPoint configuration

**Run**:
```bash
forge test --match-contract AccountWalletRegistryExtendedTest -vv
```

### 2. Integration Tests

**Smart Account Creation**:
- Create smart account
- Create with salt
- Verify address format

**Delegation**:
- Request delegation
- Check delegation status
- Revoke delegation
- Test expiry

**Advanced Permissions**:
- Request permission
- Check permission
- Revoke permission

**User Operations**:
- Batch operations
- Execute batch
- Gas estimation

**Run**:
```bash
npm test -- smart-accounts-integration
```

### 3. End-to-End Tests

**Complete Flows**:
- Create smart account → Link to fiat account → Use for payment rails
- Create smart account → Grant delegation → dApp executes transactions
- Create smart account → Grant permissions → Execute functions

**Run**:
```bash
npm test -- e2e
```

---

## Writing Tests

### Foundry Test Example

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {AccountWalletRegistryExtended} from "../../contracts/smart-accounts/AccountWalletRegistryExtended.sol";

contract MyTest is Test {
    AccountWalletRegistryExtended public registry;
    
    function setUp() public {
        // Setup test environment
        registry = new AccountWalletRegistryExtended(...);
    }
    
    function test_myFunction() public {
        // Arrange
        // Act
        // Assert
    }
}
```

### Integration Test Example

```typescript
import { SmartAccountsKit } from '@metamask/smart-accounts-kit';

describe('My Feature', () => {
  it('should work correctly', async () => {
    const kit = new SmartAccountsKit({ ... });
    const result = await kit.someFunction();
    expect(result).toBeDefined();
  });
});
```

---

## Test Data

### Test Addresses

```typescript
const TEST_ADDRESSES = {
  admin: '0x...',
  accountManager: '0x...',
  smartAccountFactory: '0x...',
  entryPoint: '0x...',
  testUser: '0x...',
  testSmartAccount: '0x...',
};
```

### Test Configuration

```typescript
const TEST_CONFIG = {
  chainId: 138,
  rpcUrl: process.env.RPC_URL_138 || 'http://192.168.11.211:8545',
  entryPointAddress: process.env.ENTRY_POINT || '0x...',
  accountFactoryAddress: process.env.ACCOUNT_FACTORY || '0x...',
};
```

---

## Test Coverage Goals

### Unit Tests
- ✅ AccountWalletRegistryExtended: 100%
- ⏳ Smart Account creation: 90%+
- ⏳ Delegation framework: 90%+
- ⏳ Advanced Permissions: 90%+

### Integration Tests
- ⏳ Smart Account creation: 100%
- ⏳ Delegation flows: 100%
- ⏳ Permission flows: 100%
- ⏳ User operations: 100%

### End-to-End Tests
- ⏳ Complete payment rail flow: 100%
- ⏳ Complete dApp interaction flow: 100%
- ⏳ Hybrid EOA + smart account flow: 100%

---

## Continuous Integration

### GitHub Actions Example

```yaml
name: Smart Accounts Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: foundry-actions/setup-foundry@v1
      - run: forge test --match-path test/smart-accounts/**
      - run: npm test
```

---

## Debugging Tests

### Foundry Debugging

```bash
# Run with maximum verbosity
forge test --match-path test/smart-accounts/** -vvvv

# Run specific test
forge test --match-test test_linkSmartAccount -vvvv

# Use debugger
forge test --debug test_linkSmartAccount
```

### Integration Test Debugging

```bash
# Run with debug output
DEBUG=* npm test

# Run single test
npm test -- --testNamePattern="should create smart account"
```

---

## Best Practices

### 1. Test Isolation

- Each test should be independent
- Use `setUp()` for common setup
- Clean up after tests

### 2. Test Coverage

- Aim for 90%+ coverage
- Test happy paths
- Test error cases
- Test edge cases

### 3. Test Naming

- Use descriptive names
- Follow pattern: `test_<functionality>`
- Group related tests

### 4. Assertions

- Use specific assertions
- Check return values
- Verify events emitted
- Check state changes

---

## Resources

- [Foundry Testing Documentation](https://book.getfoundry.sh/forge/tests)
- [Jest Documentation](https://jestjs.io/docs/getting-started)
- [Smart Accounts Developer Guide](./SMART_ACCOUNTS_DEVELOPER_GUIDE.md)

---

**Last Updated**: 2026-01-26
