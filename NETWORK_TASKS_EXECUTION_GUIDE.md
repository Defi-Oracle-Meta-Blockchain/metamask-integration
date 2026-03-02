# Network Tasks Execution Guide - Quick Reference

**Date**: 2026-01-26  
**Quick Reference**: How to execute all 22 network-dependent tasks

---

## Quick Start

### 1. Automated Execution (Recommended)

```bash
cd metamask-integration

# Execute all network-dependent tasks
./scripts/execute-network-tasks.sh all
```

### 2. Manual Execution by Phase

See [Executing Network Tasks Guide](./docs/EXECUTING_NETWORK_TASKS.md) for detailed instructions.

---

## Task Summary

| Phase | Tasks | Command |
|-------|-------|---------|
| **Deployment** | 4 tasks | `./scripts/execute-network-tasks.sh deploy` |
| **Unit Tests** | 5 tasks | `forge test --match-path test/smart-accounts/** -vv` |
| **Integration Tests** | 5 tasks | `npm test` |
| **E2E Tests** | 3 tasks | `npm run test:e2e` |
| **Security Audit** | 1 task | Contact audit firm |
| **Production** | 1 task | `./scripts/deploy-smart-accounts-complete.sh` |
| **UAT** | 1 task | Manual process |
| **Performance** | 1 task | `./scripts/performance-test.sh` |
| **Outreach** | 1 task | Video production |

---

## Prerequisites Checklist

Before executing tasks:

- [ ] Network access to ChainID 138
- [ ] RPC endpoint configured
- [ ] Deployer wallet with sufficient ETH
- [ ] Foundry installed
- [ ] Node.js v18+ installed
- [ ] Environment variables set
- [ ] Contracts ready to deploy

---

## Execution Order

1. **Deploy Contracts** (4 tasks)
2. **Run Tests** (13 tasks)
3. **Security Audit** (1 task)
4. **Production Deployment** (1 task)
5. **UAT & Performance** (2 tasks)
6. **Outreach** (1 task)

---

## Documentation

- [Detailed Execution Guide](./docs/EXECUTING_NETWORK_TASKS.md)
- [Network-Dependent Tasks List](./NETWORK_DEPENDENT_TASKS.md)
- [Deployment Checklist](./DEPLOYMENT_CHECKLIST.md)

---

**Last Updated**: 2026-01-26
