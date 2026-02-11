#!/usr/bin/env bash
# Validate that token/bridge/networks list URLs return valid JSON.
# Usage: ./validate-token-lists.sh [URL1] [URL2] ...
#   If no URLs given, reads from env: TOKEN_LIST_JSON_URL, BRIDGE_LIST_JSON_URL, NETWORKS_JSON_URL.
# Requires: curl, jq (or python3 for fallback).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VALID=0
INVALID=0

validate_url() {
  local url="$1"
  local name="${2:-$url}"
  local body
  if ! body="$(curl -sS -L --connect-timeout 15 --max-time 30 "$url" 2>/dev/null)"; then
    echo "❌ $name: failed to fetch"
    ((INVALID++)) || true
    return 1
  fi
  if [ -z "$body" ]; then
    echo "❌ $name: empty response"
    ((INVALID++)) || true
    return 1
  fi
  if command -v jq &>/dev/null; then
    if echo "$body" | jq . &>/dev/null; then
      echo "✅ $name: valid JSON"
      ((VALID++)) || true
      return 0
    fi
  else
    if echo "$body" | python3 -c "import sys,json; json.load(sys.stdin)" 2>/dev/null; then
      echo "✅ $name: valid JSON"
      ((VALID++)) || true
      return 0
    fi
  fi
  echo "❌ $name: invalid JSON"
  ((INVALID++)) || true
  return 1
}

echo "=============================================="
echo "Token / bridge / networks list JSON validation"
echo "=============================================="
echo ""

if [ $# -gt 0 ]; then
  for url in "$@"; do
    validate_url "$url" "$url"
  done
else
  for var in TOKEN_LIST_JSON_URL BRIDGE_LIST_JSON_URL NETWORKS_JSON_URL; do
    url="${!var:-}"
    if [ -n "$url" ]; then
      validate_url "$url" "$var"
    else
      echo "⏭ $var not set, skipping"
    fi
  done
  if [ "$VALID" -eq 0 ] && [ "$INVALID" -eq 0 ]; then
    echo "Set TOKEN_LIST_JSON_URL, BRIDGE_LIST_JSON_URL, or NETWORKS_JSON_URL, or pass URLs as arguments."
    exit 0
  fi
fi

echo ""
echo "Result: $VALID valid, $INVALID invalid"
if [ "$INVALID" -gt 0 ]; then
  exit 1
fi
exit 0
