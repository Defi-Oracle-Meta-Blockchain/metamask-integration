#!/usr/bin/env bash
# Run all integration tests and builds using pnpm as package manager.
# Usage: pnpm run run-all   or   ./scripts/run-all.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT="$(cd "$PROJECT_ROOT/.." && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_ok() { echo -e "${GREEN}[OK]${NC} $1"; }

log_info "Using pnpm as package manager"
command -v pnpm >/dev/null 2>&1 || { echo "pnpm not found. Install: npm install -g pnpm"; exit 1; }

# 1. Full integration script (provider test + config validation)
log_info "1. Full integration script (provider test + config validation)"
"$SCRIPT_DIR/integration-test-all.sh"
log_ok "Integration script passed"
echo ""

# 2. Token-aggregation (pnpm install + build)
TOKEN_AGG="$REPO_ROOT/smom-dbis-138/services/token-aggregation"
if [[ -d "$TOKEN_AGG" ]] && [[ -f "$TOKEN_AGG/package.json" ]]; then
  log_info "2. Token-aggregation (pnpm install + build)"
  (cd "$TOKEN_AGG" && pnpm install && pnpm run build)
  log_ok "Token-aggregation build passed"
else
  log_info "2. Token-aggregation: skip (dir not found)"
fi
echo ""

# 3. Explorer frontend (pnpm install + build)
EXPLORER_FRONT="$REPO_ROOT/explorer-monorepo/frontend"
if [[ -d "$EXPLORER_FRONT" ]] && [[ -f "$EXPLORER_FRONT/package.json" ]]; then
  log_info "3. Explorer frontend (pnpm install + build)"
  (cd "$EXPLORER_FRONT" && pnpm install && pnpm run build)
  log_ok "Explorer frontend build passed"
else
  log_info "3. Explorer frontend: skip (dir not found)"
fi
echo ""

# 4. Chain 138 Snap (yarn template; try pnpm)
SNAP_ROOT="$PROJECT_ROOT/chain138-snap"
if [[ -d "$SNAP_ROOT" ]] && [[ -f "$SNAP_ROOT/package.json" ]]; then
  log_info "4. Chain 138 Snap (pnpm install + build)"
  if (cd "$SNAP_ROOT" && pnpm install 2>/dev/null && pnpm run build 2>/dev/null); then
    log_ok "Chain 138 Snap build passed"
  else
    log_info "4. Chain 138 Snap: use yarn in template (yarn install && yarn build)"
  fi
else
  log_info "4. Chain 138 Snap: skip (dir not found)"
fi
echo ""

log_ok "Run-all complete (pnpm)"
