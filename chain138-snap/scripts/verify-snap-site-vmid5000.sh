#!/usr/bin/env bash
# Verify Chain 138 Snap site deployment on VMID 5000.
# Usage: ./verify-snap-site-vmid5000.sh [BASE_URL]
#   BASE_URL defaults to https://explorer.d-bis.org (or use http://192.168.11.140 for LAN)

set -euo pipefail

BASE_URL="${1:-https://explorer.d-bis.org}"
BASE_URL="${BASE_URL%/}"
VMID=5000
VM_IP="${EXPLORER_VM_IP:-192.168.11.140}"
PROXMOX_HOST="${PROXMOX_HOST_R630_02:-192.168.11.12}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PASS=0
FAIL=0

check() {
  local name="$1"
  if eval "$2"; then
    echo "✅ $name"
    ((PASS++)) || true
    return 0
  else
    echo "❌ $name"
    ((FAIL++)) || true
    return 1
  fi
}

echo "=============================================="
echo "Snap site (VMID $VMID) verification"
echo "BASE_URL=$BASE_URL"
echo "=============================================="
echo ""

# 1) Public URL /snap/ returns 200 (follow redirects)
HTTP_CODE="$(curl -sS -L -o /dev/null -w "%{http_code}" --connect-timeout 10 "$BASE_URL/snap/" 2>/dev/null || echo 000)"
check "$BASE_URL/snap/ returns 200" "[ \"$HTTP_CODE\" = \"200\" ]"

# 2) /snap/ response contains Snap app content (follow redirects)
SNAP_BODY="$(curl -sS -L --connect-timeout 10 "$BASE_URL/snap/" 2>/dev/null | head -c 8192)" || true
check "/snap/ contains Snap app content (Connect|Snap|MetaMask)" "echo \"$SNAP_BODY\" | grep -qE 'Connect|template-snap|Snap|MetaMask'"

# 3) /snap/index.html returns 200 (follow redirects)
HTTP_CODE="$(curl -sS -L -o /dev/null -w "%{http_code}" --connect-timeout 10 "$BASE_URL/snap/index.html" 2>/dev/null || echo 000)"
check "$BASE_URL/snap/index.html returns 200" "[ \"$HTTP_CODE\" = \"200\" ]"

# 4) Optional: /snap/version.json returns 200 and valid JSON (build version/health)
VERSION_CODE="$(curl -sS -L -o /dev/null -w "%{http_code}" --connect-timeout 5 "$BASE_URL/snap/version.json" 2>/dev/null || echo 000)"
if [ "$VERSION_CODE" = "200" ]; then
  echo "✅ $BASE_URL/snap/version.json returns 200 (build version/health)"
  ((PASS++)) || true
else
  echo "⏭ $BASE_URL/snap/version.json returned $VERSION_CODE (optional; set prebuild to generate)"
fi

# 6) Optional: when pct or SSH available, check inside VM
if command -v pct &>/dev/null; then
  if pct exec $VMID -- test -f /var/www/html/snap/index.html 2>/dev/null; then
    echo "✅ /var/www/html/snap/index.html exists in VM"
    ((PASS++)) || true
  fi
  if pct exec $VMID -- grep -q 'location /snap/' /etc/nginx/sites-available/blockscout 2>/dev/null; then
    echo "✅ Nginx has location /snap/ in VM"
    ((PASS++)) || true
  fi
elif ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no root@"${PROXMOX_HOST}" "pct exec $VMID -- test -f /var/www/html/snap/index.html" 2>/dev/null; then
  echo "✅ /var/www/html/snap/index.html exists in VM (via SSH)"
  ((PASS++)) || true
fi

echo ""
echo "=============================================="
echo "Result: $PASS passed, $FAIL failed"
echo "=============================================="
if [ "$FAIL" -gt 0 ]; then
  echo ""
  echo "See: $SCRIPT_DIR/../DEPLOY_VMID5000.md"
  exit 1
fi
exit 0
