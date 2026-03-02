# Chain 138 Snap — Documentation index

Documentation for the **Chain 138 Snap** (MetaMask): network params, token list, market data, swap quotes, and CCIP and Trustless bridge routes for Chain 138 and ALL Mainnet.

## Quick links

| Doc                                                  | Description                                                                                                         |
| ---------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| [FEATURES.md](FEATURES.md)                           | **All RPC methods and features** — method matrix, params, response shapes, blockchains (138 + 651940), flow diagram |
| [CONTRIBUTING.md](CONTRIBUTING.md)                   | How to contribute: setup, testing, linting, publishing                                                              |
| [FAQ.md](FAQ.md)                                     | Frequently asked questions about the Snap                                                                           |
| [DEPLOY_COMPANION_SITE.md](DEPLOY_COMPANION_SITE.md) | Build and deploy the companion site to your own host                                                                |
| [RUNBOOK.md](RUNBOOK.md)                             | Build, test, publish quick reference                                                                                |

## Root-level docs (repo root)

| Doc                                                                                          | Description                                                 |
| -------------------------------------------------------------------------------------------- | ----------------------------------------------------------- |
| [README](../README.md)                                                                       | Project overview, getting started                           |
| [INTEGRATORS](../INTEGRATORS.md)                                                             | Integrator guide: Snap ID, apiBaseUrl, RPC methods          |
| [TESTING_INSTRUCTIONS](../TESTING_INSTRUCTIONS.md)                                           | Full testing guide: dev server, RPC examples, E2E checklist |
| [E2E_PREPARATION](../E2E_PREPARATION.md)                                                     | Token-aggregation and companion site setup for E2E          |
| [MANUAL_E2E_CHECKLIST](../MANUAL_E2E_CHECKLIST.md)                                           | Short manual E2E checklist                                  |
| [PUSH_AND_PUBLISH](../PUSH_AND_PUBLISH.md)                                                   | Push to GitHub, publish to npm, allowlist                   |
| [PACKAGE_MANAGER](../PACKAGE_MANAGER.md)                                                     | pnpm vs Yarn                                                |
| [SECURITY](../SECURITY.md)                                                                   | Security notes: HTTPS, API, permissions                     |
| [ALLOWLIST_FORM_FIELDS](../ALLOWLIST_FORM_FIELDS.md)                                         | MetaMask allowlist form fields                              |
| [ALLOWLIST_SOURCE_AND_COMPLIANCE_CHECKLIST](../ALLOWLIST_SOURCE_AND_COMPLIANCE_CHECKLIST.md) | Allowlist compliance checklist                              |
| [NEXT_STEPS](../NEXT_STEPS.md)                                                               | Completed items and future releases                         |

## Visual elements

- **Feature overview and method matrix:** [FEATURES.md](FEATURES.md) includes ASCII feature overview, RPC method matrix (all methods × Chain 138 / ALL Mainnet × params × UI), and a Mermaid request-flow diagram.
- **Screenshots:** Optional screenshots (Connect UI, market data dialog, bridge dialog, swap quote dialog) can be added under [docs/images/](images/). See the "Screenshots and visuals" section in [FEATURES.md](FEATURES.md) for suggested filenames.

## Snap package (npm)

The published Snap package has its own README on npm; a copy lives in [packages/snap/README.md](../packages/snap/README.md).
