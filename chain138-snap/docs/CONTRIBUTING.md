# Contributing to Chain 138 Snap

Thank you for your interest in contributing. This guide covers setup, testing, and publishing.

## Prerequisites

- **Node.js** 18.6.0 or later (LTS recommended)
- **pnpm** (default) or **Yarn** — see [PACKAGE_MANAGER.md](../PACKAGE_MANAGER.md)

## Setup

```bash
# Clone the repo (or your fork)
git clone https://github.com/bis-innovations/chain138-snap.git
cd chain138-snap

# Install dependencies (pnpm default)
pnpm install

# Optional: enable scripts for packages that need postinstall (e.g. sharp)
pnpm run allow-scripts
```

## Development

- **Start dev server** (Snap + companion site): `pnpm run start` — serves at http://localhost:8000
- **Build:** `pnpm run build` — builds Snap and site
- **Lint:** `pnpm run lint` — ESLint + Prettier (JSON/MD/YAML)
- **Lint fix:** `pnpm run lint:fix`

## Testing

- **Unit tests (Snap):** `pnpm run test` — builds the Snap and runs Jest in packages/snap
- **E2E (Playwright):** `pnpm run test:e2e` — runs Playwright against the companion site (first time: `npx playwright install`)

For full manual E2E (MetaMask Flask, all RPC methods), see [TESTING_INSTRUCTIONS.md](../TESTING_INSTRUCTIONS.md) and [E2E_PREPARATION.md](../E2E_PREPARATION.md).

## Packages with scripts

Scripts are disabled by default (LavaMoat). If you need to run install scripts (e.g. for sharp or gatsby):

```bash
pnpm run allow-scripts
```

Then enable the package in the lavamoat.allowScripts section of the root package.json if required.

## Submitting changes

1. Create a branch, make your changes, and run `pnpm run lint` and `pnpm run test`.
2. Open a pull request against main.
3. Ensure CI passes (build, lint, tests, and any security workflows).

## Publishing (maintainers)

- **Push to GitHub:** See [PUSH_AND_PUBLISH.md](../PUSH_AND_PUBLISH.md) (subtree push from parent repo if applicable).
- **Publish to npm:** From this repo root, `pnpm run publish:snap` (requires NPM_ACCESS_TOKEN in .env for 2FA bypass; see .env.example).
- **Allowlist:** After publishing a new version, submit an update via the MetaMask Snaps Directory Information Update form if the Snap is already allowlisted.

## Code of conduct

Be respectful and constructive. Report security issues privately (see [SECURITY.md](../SECURITY.md)).
