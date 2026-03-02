#!/usr/bin/env bash
# Full integration test: provider, explorer config, optional explorer API and token-aggregation API.
# Usage: ./scripts/integration-test-all.sh
# Optional env: EXPLORER_API_URL (e.g. http://localhost:8080), TOKEN_AGGREGATION_URL (e.g. http://localhost:3000)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# Repo root: parent of metamask-integration (proxmox workspace)
REPO_ROOT="$(cd "$PROJECT_ROOT/.." && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_ok() { echo -e "${GREEN}[PASS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_fail() { echo -e "${RED}[FAIL]${NC} $1"; }

PASSED=0
FAILED=0

# --- 1. Provider integration test (Node) ---
log_info "========================================="
log_info "1. Provider integration test"
log_info "========================================="
if (cd "$PROJECT_ROOT/provider" && node test-integration.mjs); then
  log_ok "Provider test passed"
  PASSED=$((PASSED + 1))
else
  log_fail "Provider test failed"
  FAILED=$((FAILED + 1))
fi
echo ""

# --- 2. Validate explorer config JSONs (in-repo) ---
log_info "========================================="
log_info "2. Validate explorer config JSONs"
log_info "========================================="
CONFIG_DIR="$REPO_ROOT/docs/04-configuration/metamask"
NETWORKS_JSON="$CONFIG_DIR/DUAL_CHAIN_NETWORKS.json"
TOKENLIST_JSON="$CONFIG_DIR/DUAL_CHAIN_TOKEN_LIST.tokenlist.json"

validate_networks() {
  if [[ ! -f "$NETWORKS_JSON" ]]; then
    log_fail "Missing $NETWORKS_JSON"
    return 1
  fi
  local chains
  chains=$(node -e "
    const fs = require('fs');
    const path = process.argv[1];
    const data = JSON.parse(fs.readFileSync(path, 'utf8'));
    if (!data.chains || !Array.isArray(data.chains)) { process.exit(1); }
    const ids = data.chains.map(c => c.chainIdDecimal || c.chainId).filter(Boolean);
    if (!ids.includes(138) || !ids.includes(1)) { process.exit(2); }
    console.log(ids.join(','));
  " "$NETWORKS_JSON" 2>/dev/null) || true
  if [[ -z "$chains" ]]; then
    log_fail "DUAL_CHAIN_NETWORKS.json invalid or missing chain 138/1"
    return 1
  fi
  log_ok "DUAL_CHAIN_NETWORKS.json valid (chains: $chains)"
  return 0
}

validate_tokenlist() {
  if [[ ! -f "$TOKENLIST_JSON" ]]; then
    log_fail "Missing $TOKENLIST_JSON"
    return 1
  fi
  local ok
  ok=$(node -e "
    const fs = require('fs');
    const path = process.argv[1];
    const data = JSON.parse(fs.readFileSync(path, 'utf8'));
    if (!data.tokens || !Array.isArray(data.tokens)) { process.exit(1); }
    const chainIds = [...new Set(data.tokens.map(t => t.chainId))];
    console.log(chainIds.join(','));
  " "$TOKENLIST_JSON" 2>/dev/null) || true
  if [[ -z "$ok" ]]; then
    log_fail "DUAL_CHAIN_TOKEN_LIST.tokenlist.json invalid (no tokens array)"
    return 1
  fi
  log_ok "DUAL_CHAIN_TOKEN_LIST.tokenlist.json valid (chainIds: $ok)"
  return 0
}

if validate_networks; then PASSED=$((PASSED + 1)); else FAILED=$((FAILED + 1)); fi
if validate_tokenlist; then PASSED=$((PASSED + 1)); else FAILED=$((FAILED + 1)); fi
echo ""

# --- 3. Optional: Explorer API (config endpoints) ---
EXPLORER_API_URL="${EXPLORER_API_URL:-}"
if [[ -n "$EXPLORER_API_URL" ]]; then
  log_info "========================================="
  log_info "3. Explorer API ($EXPLORER_API_URL)"
  log_info "========================================="
  if curl -sf --max-time 10 "$EXPLORER_API_URL/api/config/networks" | node -e "
    const chunks = [];
    process.stdin.on('data', c => chunks.push(c));
    process.stdin.on('end', () => {
      const data = JSON.parse(Buffer.concat(chunks).toString());
      if (!data.chains || !data.chains.length) process.exit(1);
      const has138 = data.chains.some(c => (c.chainIdDecimal || c.chainId) == 138);
      if (!has138) process.exit(2);
      console.log('ok');
    });
  " 2>/dev/null; then
    log_ok "GET /api/config/networks OK"
    PASSED=$((PASSED + 1))
  else
    log_fail "GET /api/config/networks failed or invalid"
    FAILED=$((FAILED + 1))
  fi
  if curl -sf --max-time 10 "$EXPLORER_API_URL/api/config/token-list" | node -e "
    const chunks = [];
    process.stdin.on('data', c => chunks.push(c));
    process.stdin.on('end', () => {
      const data = JSON.parse(Buffer.concat(chunks).toString());
      if (!data.tokens || !Array.isArray(data.tokens)) process.exit(1);
      console.log('ok');
    });
  " 2>/dev/null; then
    log_ok "GET /api/config/token-list OK"
    PASSED=$((PASSED + 1))
  else
    log_fail "GET /api/config/token-list failed or invalid"
    FAILED=$((FAILED + 1))
  fi
  echo ""
else
  log_info "Skip Explorer API (set EXPLORER_API_URL to test)"
fi

# --- 4. Optional: Token-aggregation API ---
TOKEN_AGGREGATION_URL="${TOKEN_AGGREGATION_URL:-}"
if [[ -n "$TOKEN_AGGREGATION_URL" ]]; then
  log_info "========================================="
  log_info "4. Token-aggregation API ($TOKEN_AGGREGATION_URL)"
  log_info "========================================="
  if curl -sf --max-time 10 "$TOKEN_AGGREGATION_URL/api/v1/chains" | node -e "
    const chunks = [];
    process.stdin.on('data', c => chunks.push(c));
    process.stdin.on('end', () => {
      const data = JSON.parse(Buffer.concat(chunks).toString());
      if (!data.chains || !data.chains.length) process.exit(1);
      const has138 = data.chains.some(c => c.chainId === 138);
      if (!has138) process.exit(2);
      console.log('ok');
    });
  " 2>/dev/null; then
    log_ok "GET /api/v1/chains OK"
    PASSED=$((PASSED + 1))
  else
    log_fail "GET /api/v1/chains failed or invalid"
    FAILED=$((FAILED + 1))
  fi
  echo ""
else
  log_info "Skip Token-aggregation API (set TOKEN_AGGREGATION_URL to test)"
fi

# --- Summary ---
log_info "========================================="
log_info "Summary"
log_info "========================================="
echo "Passed: $PASSED, Failed: $FAILED"
if [[ $FAILED -gt 0 ]]; then
  exit 1
fi
exit 0
