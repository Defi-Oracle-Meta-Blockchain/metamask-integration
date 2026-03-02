# Chain 138 Snap — Runbook

Quick reference for building, testing, and publishing the Snap and companion site.

## Build

```bash
# Snap + site
pnpm run build

# Companion site only (e.g. for deploy)
GATSBY_PATH_PREFIX=/snap pnpm --filter site run build
# With production API:
# GATSBY_SNAP_API_BASE_URL=https://your-token-aggregation-api.com
```

## Test

```bash
pnpm run test          # Snap unit tests (Jest)
pnpm run test:e2e      # Playwright E2E (companion site)
pnpm run lint          # ESLint + Prettier
```

## Publish Snap to npm

From repo root:

```bash
pnpm run build
pnpm run publish:snap   # uses NPM_ACCESS_TOKEN from .env if set
```

See [PUSH_AND_PUBLISH.md](../PUSH_AND_PUBLISH.md).

## Deploy companion site

Build with path prefix and API URL, then upload `packages/site/public/` to your static host. See [DEPLOY_COMPANION_SITE.md](DEPLOY_COMPANION_SITE.md).

## Validate token/list URLs

```bash
./scripts/validate-token-lists.sh [URL1] [URL2] ...
# Or set TOKEN_LIST_JSON_URL, BRIDGE_LIST_JSON_URL, NETWORKS_JSON_URL
```
