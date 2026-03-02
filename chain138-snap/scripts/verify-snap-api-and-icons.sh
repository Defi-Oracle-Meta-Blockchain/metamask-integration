#!/usr/bin/env bash
# Verify token-aggregation API reachability, CORS, token logoURIs, and network iconUrls.
# Usage: ./verify-snap-api-and-icons.sh [API_BASE_URL]
#   API_BASE_URL defaults to https://explorer.d-bis.org or from GATSBY_SNAP_API_BASE_URL.
# Requires: curl, jq

set -euo pipefail

API_BASE="${1:-${GATSBY_SNAP_API_BASE_URL:-https://explorer.d-bis.org}}"
API_BASE="${API_BASE%/}"
TOKEN_LIST_URL="${API_BASE}/api/v1/report/token-list?chainId=138"
NETWORKS_URL="${API_BASE}/api/v1/networks"

PASS=0
FAIL=0

check() {
  if "$@"; then
    ((PASS++)) || true
    return 0
  else
    ((FAIL++)) || true
    return 1
  fi
}

echo "=============================================="
echo "Chain 138 Snap — API and Icons Verification"
echo "API base: $API_BASE"
echo "=============================================="
echo ""

# 1. Token list reachable
echo "1. Token list API reachable"
if body=$(curl -sS -L --connect-timeout 15 --max-time 30 "$TOKEN_LIST_URL" 2>/dev/null) && [ -n "$body" ]; then
  if echo "$body" | jq -e . &>/dev/null; then
    if echo "$body" | jq -e '.tokens' &>/dev/null; then
      echo "   ✅ $TOKEN_LIST_URL returns valid token list JSON"
      ((PASS++)) || true
    else
      echo "   ❌ $TOKEN_LIST_URL returns JSON but no .tokens (proxy may route to wrong backend)"
      ((FAIL++)) || true
    fi
  else
    echo "   ❌ $TOKEN_LIST_URL returns invalid JSON"
    ((FAIL++)) || true
  fi
else
  echo "   ❌ $TOKEN_LIST_URL failed to fetch"
  ((FAIL++)) || true
  body=""
fi
echo ""

# 2. Networks API reachable
echo "2. Networks API reachable"
if net_body=$(curl -sS -L --connect-timeout 15 --max-time 30 "$NETWORKS_URL" 2>/dev/null) && [ -n "$net_body" ]; then
  if echo "$net_body" | jq -e . &>/dev/null; then
    if echo "$net_body" | jq -e '.networks' &>/dev/null; then
      echo "   ✅ $NETWORKS_URL returns valid networks JSON"
      ((PASS++)) || true
    else
      echo "   ❌ $NETWORKS_URL returns JSON but no .networks (proxy may route to wrong backend)"
      ((FAIL++)) || true
    fi
  else
    echo "   ❌ $NETWORKS_URL returns invalid JSON"
    ((FAIL++)) || true
  fi
else
  echo "   ❌ $NETWORKS_URL failed to fetch"
  ((FAIL++)) || true
  net_body=""
fi
echo ""

# 3. CORS headers (allow browser/MetaMask fetch)
echo "3. CORS headers"
cors_headers=$(curl -sS -I -X OPTIONS -H "Origin: https://explorer.d-bis.org" -H "Access-Control-Request-Method: GET" "$TOKEN_LIST_URL" 2>/dev/null || true)
if echo "$cors_headers" | grep -qi "access-control-allow-origin"; then
  echo "   ✅ CORS headers present (token-aggregation uses cors())"
  ((PASS++)) || true
else
  echo "   ⚠ CORS headers not detected (OPTIONS preflight). GET may still work if server allows *."
  echo "   Token-aggregation uses cors() by default; verify in browser if issues occur."
fi
echo ""

# 4. Every token has logoURI
echo "4. Token logoURI"
if [ -n "$body" ]; then
  missing=$(echo "$body" | jq -r '.tokens[]? | select(.logoURI == null or .logoURI == "") | .symbol' 2>/dev/null || true)
  if [ -z "$missing" ]; then
    count=$(echo "$body" | jq '.tokens | length' 2>/dev/null || echo 0)
    echo "   ✅ All $count tokens have logoURI"
    ((PASS++)) || true
  else
    echo "   ❌ Tokens missing logoURI: $missing"
    ((FAIL++)) || true
  fi
else
  echo "   ⏭ Skipped (token list not fetched)"
fi
echo ""

# 5. List-level logoURI
echo "5. List-level logoURI"
if [ -n "$body" ]; then
  list_logo=$(echo "$body" | jq -r '.logoURI // empty' 2>/dev/null)
  if [ -n "$list_logo" ]; then
    echo "   ✅ List logoURI: $list_logo"
    ((PASS++)) || true
  else
    echo "   ⚠ List-level logoURI missing (optional)"
  fi
else
  echo "   ⏭ Skipped (token list not fetched)"
fi
echo ""

# 6. Network iconUrls
echo "6. Network iconUrls"
if [ -n "$net_body" ]; then
  missing=$(echo "$net_body" | jq -r '.networks[]? | select(.iconUrls == null or (.iconUrls | length) == 0) | "\(.chainName) (\(.chainIdDecimal))"' 2>/dev/null || true)
  if [ -z "$missing" ]; then
    count=$(echo "$net_body" | jq '.networks | length' 2>/dev/null || echo 0)
    echo "   ✅ All $count networks have iconUrls"
    ((PASS++)) || true
  else
    echo "   ❌ Networks missing iconUrls: $missing"
    ((FAIL++)) || true
  fi
else
  echo "   ⏭ Skipped (networks not fetched)"
fi
echo ""

# 7. Sample logo URL reachable
echo "7. Sample logo URLs"
if [ -n "$body" ]; then
  sample_logo=$(echo "$body" | jq -r '.tokens[0].logoURI // empty' 2>/dev/null)
  if [ -n "$sample_logo" ]; then
    if curl -sS -o /dev/null -w "%{http_code}" -L --connect-timeout 10 "$sample_logo" 2>/dev/null | grep -qE "^(200|301|302)$"; then
      echo "   ✅ Sample logo reachable: ${sample_logo:0:60}..."
      ((PASS++)) || true
    else
      echo "   ⚠ Sample logo may be unreachable: $sample_logo"
    fi
  fi
fi
echo ""

echo "=============================================="
echo "Result: $PASS passed, $FAIL failed"
echo "=============================================="
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
exit 0
