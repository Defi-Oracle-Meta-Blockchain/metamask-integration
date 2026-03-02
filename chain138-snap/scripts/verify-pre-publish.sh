#!/usr/bin/env bash
# Run automatable items from docs/PRE_PUBLISH_TESTING.md (build, test, package contents, optional lint).
# Usage: [SKIP_LINT=1] [SKIP_E2E=1] bash scripts/verify-pre-publish.sh

set -e

cd "$(dirname "$0")/.."
ROOT="$PWD"

echo "=== Verify pre-publish (automatable items) ==="

echo "[1/5] Build..."
pnpm run build

echo "[2/5] Unit tests..."
pnpm run test

echo "[3/5] Package contents..."
SNAP_DIR="$ROOT/packages/snap"
for f in dist/bundle.js images/icon.svg snap.manifest.json; do
  if [ ! -f "$SNAP_DIR/$f" ]; then
    echo "Missing: packages/snap/$f"
    exit 1
  fi
done
echo "  dist/bundle.js, images/icon.svg, snap.manifest.json OK"

echo "[4/5] Manifest vs package.json version..."
MANIFEST_VER=$(jq -r .version "$SNAP_DIR/snap.manifest.json")
PKG_VER=$(jq -r .version "$SNAP_DIR/package.json")
if [ "$MANIFEST_VER" != "$PKG_VER" ]; then
  echo "Version mismatch: snap.manifest.json=$MANIFEST_VER package.json=$PKG_VER"
  exit 1
fi
echo "  Version $MANIFEST_VER OK"

if [ "${SKIP_LINT:-0}" != "1" ]; then
  echo "[5/5] Lint (Prettier only; ESLint may have existing rules)..."
  pnpm run lint:misc --check
else
  echo "[5/5] Lint skipped (SKIP_LINT=1)"
fi

if [ "${SKIP_E2E:-0}" != "1" ]; then
  echo "[E2E] Playwright (optional)..."
  if pnpm run test:e2e 2>/dev/null; then
    echo "  E2E passed"
  else
    echo "  E2E failed or not run (run 'npx playwright install' once if needed)"
  fi
else
  echo "[E2E] Skipped (SKIP_E2E=1)"
fi

echo "=== Automatable checks done. Complete manual items in docs/PRE_PUBLISH_TESTING.md ==="
