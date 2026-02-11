#!/bin/bash
# Deploy Chain 138 Snap companion site to VMID 5000 (explorer host).
# Serves the site at https://explorer.d-bis.org/snap/
# Requires: built site (run with --build to build first), Proxmox host with pct or SSH.

set -euo pipefail

VMID=5000
VM_IP="${EXPLORER_VM_IP:-192.168.11.140}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SNAP_REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SITE_PUBLIC="${SNAP_REPO_ROOT}/packages/site/public"
PROXMOX_HOST="${PROXMOX_HOST_R630_02:-192.168.11.12}"

BUILD_FIRST=false
for arg in "$@"; do
  [ "$arg" = "--build" ] && BUILD_FIRST=true
done

echo "=========================================="
echo "Deploy Chain 138 Snap site to VMID $VMID"
echo "=========================================="
echo ""

if [ "$BUILD_FIRST" = true ]; then
  echo "=== Building site (pathPrefix=/snap) ==="
  BUILD_ENV="GATSBY_PATH_PREFIX=/snap GATSBY_BUILD_SHA=$(git rev-parse --short HEAD 2>/dev/null || echo 'unknown')"
  [ -n "${GATSBY_SNAP_API_BASE_URL:-}" ] && BUILD_ENV="$BUILD_ENV GATSBY_SNAP_API_BASE_URL=$GATSBY_SNAP_API_BASE_URL"
  (cd "$SNAP_REPO_ROOT" && eval "$BUILD_ENV" pnpm --filter site run build)
  echo ""
fi

if [ ! -f "${SITE_PUBLIC}/index.html" ]; then
  echo "❌ Site not built. Run from repo root: GATSBY_PATH_PREFIX=/snap pnpm --filter site run build"
  echo "   Or run this script with: $0 --build"
  echo "   For production API (market/bridge/swap): GATSBY_SNAP_API_BASE_URL=https://your-api.com $0 --build"
  exit 1
fi

# Detect run context
if [ -f "/proc/1/cgroup" ] && grep -q "lxc" /proc/1/cgroup 2>/dev/null; then
  echo "Running inside VMID $VMID"
  DEPLOY_METHOD="direct"
  run_in_vm() { "$@"; }
elif command -v pct &>/dev/null; then
  echo "Running from Proxmox host (pct exec $VMID)"
  DEPLOY_METHOD="pct"
  run_in_vm() { pct exec $VMID -- "$@"; }
else
  echo "Running from remote (SSH to $PROXMOX_HOST, then pct to $VMID)"
  DEPLOY_METHOD="remote"
  run_in_vm() { ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no root@"${PROXMOX_HOST}" "pct exec $VMID -- $*"; }
fi

echo "=== Creating tarball of site ==="
TARBALL="/tmp/snap-site-deploy-$$.tar"
(cd "$SITE_PUBLIC" && tar -cf "$TARBALL" .)
cleanup_tarball() { rm -f "$TARBALL"; }
trap cleanup_tarball EXIT
echo "✅ Tarball: $TARBALL"
# Keep last tarball for rollback (on host: /tmp/snap-site-last.tar; in VM: previous files overwritten)
LAST_TARBALL="/tmp/snap-site-last.tar"
cp "$TARBALL" "$LAST_TARBALL" 2>/dev/null || true
echo "✅ Rollback tarball saved: $LAST_TARBALL"
echo ""

echo "=== Deploying to /var/www/html/snap/ ==="
# Optional: backup current deploy for rollback (inside VM)
run_in_vm "mkdir -p /var/www/html/snap"
run_in_vm "tar -cf /var/www/html/snap-rollback.tar -C /var/www/html/snap . 2>/dev/null || true"
if [ "$DEPLOY_METHOD" = "direct" ]; then
  tar -xf "$TARBALL" -C /var/www/html/snap
  chown -R www-data:www-data /var/www/html/snap
elif [ "$DEPLOY_METHOD" = "remote" ]; then
  TARNAME="$(basename "$TARBALL")"
  scp -o ConnectTimeout=10 -o StrictHostKeyChecking=no "$TARBALL" root@"${PROXMOX_HOST}":/tmp/
  ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no root@"${PROXMOX_HOST}" "pct push $VMID /tmp/$TARNAME /tmp/snap-deploy.tar"
  run_in_vm "tar -xf /tmp/snap-deploy.tar -C /var/www/html/snap"
  run_in_vm "rm -f /tmp/snap-deploy.tar"
  run_in_vm "chown -R www-data:www-data /var/www/html/snap"
  ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no root@"${PROXMOX_HOST}" "rm -f /tmp/$TARNAME"
else
  pct push $VMID "$TARBALL" /tmp/snap-deploy.tar
  run_in_vm "tar -xf /tmp/snap-deploy.tar -C /var/www/html/snap"
  run_in_vm "rm -f /tmp/snap-deploy.tar"
  run_in_vm "chown -R www-data:www-data /var/www/html/snap"
fi
echo "✅ Files deployed"
echo ""

echo "=== Nginx: ensure /snap/ is served ==="
if run_in_vm "grep -q 'location /snap/' /etc/nginx/sites-available/blockscout 2>/dev/null"; then
  echo "✅ Nginx already has location /snap/"
  run_in_vm "nginx -t && systemctl reload nginx" 2>/dev/null || true
else
  echo "⚠️  Add location /snap/ to nginx on VMID $VMID (e.g. run explorer-monorepo scripts/fix-nginx-serve-custom-frontend.sh inside the VM)"
fi
echo ""

echo "=== Verification checks ==="
VERIFY_FAIL=0
if run_in_vm "test -f /var/www/html/snap/index.html"; then
  echo "✅ /var/www/html/snap/index.html exists"
else
  echo "❌ /var/www/html/snap/index.html missing"
  VERIFY_FAIL=1
fi
if run_in_vm "grep -q 'location /snap/' /etc/nginx/sites-available/blockscout 2>/dev/null"; then
  echo "✅ Nginx config has location /snap/"
else
  echo "❌ Nginx config missing location /snap/"
  VERIFY_FAIL=1
fi
SNAP_CODE="$(run_in_vm "curl -sS -o /dev/null -w '%{http_code}' --connect-timeout 5 http://127.0.0.1/snap/ 2>/dev/null" 2>/dev/null || echo "000")"
if [ "$SNAP_CODE" = "200" ]; then
  echo "✅ http://localhost/snap/ returns 200"
else
  echo "❌ http://localhost/snap/ returned $SNAP_CODE (expected 200)"
  VERIFY_FAIL=1
fi
SNAP_BODY="$(run_in_vm "curl -sS --connect-timeout 5 http://127.0.0.1/snap/ 2>/dev/null | head -c 4096" 2>/dev/null || true)"
if echo "$SNAP_BODY" | grep -qE 'Connect|template-snap|Snap|MetaMask'; then
  echo "✅ /snap/ response contains Snap app content"
else
  echo "⚠️  /snap/ response may not contain expected content (check in browser)"
fi
if [ "$VERIFY_FAIL" -eq 1 ]; then
  echo ""
  echo "⚠️  Some checks failed; see above. Snap may still work if nginx is updated."
fi
echo ""

echo "=========================================="
echo "Deployment complete"
echo "=========================================="
echo "Snap site should be available at:"
echo "  - https://explorer.d-bis.org/snap/"
echo "  - http://${VM_IP}/snap/"
echo ""
echo "Run full verification: metamask-integration/chain138-snap/scripts/verify-snap-site-vmid5000.sh"
echo "Or explorer + snap: explorer-monorepo/scripts/verify-vmid5000-all.sh"
echo ""
echo "Rollback: re-deploy previous build with: run_in_vm 'tar -xf /var/www/html/snap-rollback.tar -C /var/www/html/snap' (or use $LAST_TARBALL from host)."
echo ""
