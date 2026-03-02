#!/usr/bin/env bash
# Build the Snap companion site for https://explorer.d-bis.org/snap/
# Uses GATSBY_SNAP_API_BASE_URL=https://explorer.d-bis.org so Market data, Bridge, Swap cards work.
# For that to work, explorer.d-bis.org must serve the token-aggregation API at /api/v1/... (deploy
# smom-dbis-138/services/token-aggregation and proxy it, or set GATSBY_SNAP_API_BASE_URL to the API host).
# Output: packages/site/public/ (upload to /var/www/html/snap/ on VMID 5000).
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT"
export GATSBY_PATH_PREFIX=/snap
export GATSBY_SNAP_API_BASE_URL="${GATSBY_SNAP_API_BASE_URL:-https://explorer.d-bis.org}"
# So "Send on Chain 138" link is absolute HTTPS (avoids redirect to http and mixed-content).
export GATSBY_SNAP_SITE_URL="${GATSBY_SNAP_SITE_URL:-https://explorer.d-bis.org}"
# Production: use npm snap so MetaMask does not try to fetch localhost:8080 (GATSBY_* is inlined into client bundle).
export GATSBY_SNAP_ORIGIN="${GATSBY_SNAP_ORIGIN:-npm:chain138-snap}"
# Required for Gatsby to apply pathPrefix to script/asset URLs (see path prefix docs).
export PREFIX_PATHS=1
echo "Building Snap site: GATSBY_PATH_PREFIX=$GATSBY_PATH_PREFIX GATSBY_SNAP_SITE_URL=$GATSBY_SNAP_SITE_URL PREFIX_PATHS=$PREFIX_PATHS GATSBY_SNAP_ORIGIN=$GATSBY_SNAP_ORIGIN GATSBY_SNAP_API_BASE_URL=$GATSBY_SNAP_API_BASE_URL"
pnpm --filter site run build
echo "Done. Output in packages/site/public/ — deploy to /var/www/html/snap/ on explorer VM (VMID 5000)."
