#!/usr/bin/env bash
# Deprecated shim for the old monolithic explorer deployment path.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

cat <<EOF
[deprecated] metamask-integration/scripts/deploy-to-explorer.sh no longer deploys the live explorer.

The old monolithic path created a separate frontend directory and a now-retired frontend unit.
That deployment shape has been retired and pruned from the live stack.

Use the canonical explorer deployment scripts instead:
  Frontend:  $REPO_ROOT/explorer-monorepo/scripts/deploy-next-frontend-to-vmid5000.sh
  API/config: $REPO_ROOT/explorer-monorepo/scripts/deploy-explorer-ai-to-vmid5000.sh
  Static config: $REPO_ROOT/explorer-monorepo/scripts/deploy-explorer-config-to-vmid5000.sh

If you need the Snap companion refreshed, rebuild and sync the site bundle from:
  $REPO_ROOT/metamask-integration/chain138-snap/
EOF

exit 1
