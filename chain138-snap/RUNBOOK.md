# Chain 138 Snap Runbook

Quick reference for building, deploying, and verifying the Snap companion site.

## Build

```bash
GATSBY_PATH_PREFIX=/snap GATSBY_BUILD_SHA=$(git rev-parse --short HEAD) pnpm --filter site run build
# Production API (market/bridge/swap):
# GATSBY_SNAP_API_BASE_URL=https://your-token-aggregation-api.com
```

## Deploy to VMID 5000

```bash
./scripts/deploy-snap-site-to-vmid5000.sh --build   # build + deploy
GATSBY_SNAP_API_BASE_URL=https://your-api.com ./scripts/deploy-snap-site-to-vmid5000.sh --build  # production API
./scripts/deploy-snap-site-to-vmid5000.sh          # deploy existing build
```

## Verify

```bash
./scripts/verify-snap-site-vmid5000.sh [BASE_URL]
# Full explorer + API + Snap:
# cd ../explorer-monorepo && ./scripts/verify-vmid5000-all.sh [BASE_URL]
```

## Rollback

See `explorer-monorepo/RUNBOOK.md` (rollback from VM or from host using `/tmp/snap-site-last.tar`).

## Nginx

From Proxmox host: `cd explorer-monorepo && ./scripts/apply-nginx-snap-vmid5000.sh`. Or inside VMID 5000: `explorer-monorepo/scripts/fix-nginx-serve-custom-frontend.sh`. Ensures `/snap` and `/snap/` return 200 with content.

## Token / bridge list validation

```bash
./scripts/validate-token-lists.sh [URL1] [URL2] ...
# Or set TOKEN_LIST_JSON_URL, BRIDGE_LIST_JSON_URL, NETWORKS_JSON_URL
```

## URLs

- Production: https://explorer.d-bis.org/snap/
- Version/health: https://explorer.d-bis.org/snap/version.json

See also `DEPLOY_VMID5000.md` and `explorer-monorepo/RUNBOOK.md`.
