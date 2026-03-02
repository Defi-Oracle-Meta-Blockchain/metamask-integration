#!/usr/bin/env bash
# Deploy all MetaMask integration changes to explorer.d-bis.org (VMID 5000)
# Phases: 1) Backend API, 2) Frontend, 3) Verify, 4) Optional enhancements

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# VMID 5000 connection
VMID=5000
VMID_IP="192.168.11.140"
PROXMOX_HOST="192.168.11.12"  # r630-02
PROXMOX_USER="${PROXMOX_USER:-root}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_ok() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_fail() { echo -e "${RED}[FAIL]${NC} $1"; }

# Check SSH access
check_access() {
  log_info "Checking access to VMID $VMID..."
  if ! ssh -o ConnectTimeout=5 -o BatchMode=yes "$PROXMOX_USER@$PROXMOX_HOST" "pct status $VMID" &>/dev/null; then
    log_fail "Cannot access VMID $VMID via $PROXMOX_HOST. Check SSH keys and network."
    exit 1
  fi
  log_ok "Access confirmed"
}

# Phase 1: Deploy backend API with config routes
deploy_backend_api() {
  log_info "========================================="
  log_info "PHASE 1: Deploy backend API (config routes)"
  log_info "========================================="
  
  # Build Go API
  log_info "Building Go API..."
  (cd "$REPO_ROOT/explorer-monorepo/backend" && go build -o bin/api-server ./api/rest/cmd/)
  log_ok "Go API built: explorer-monorepo/backend/bin/api-server"
  
  # Copy to VMID 5000
  log_info "Copying API server to VMID $VMID..."
  scp -o ConnectTimeout=10 "$REPO_ROOT/explorer-monorepo/backend/bin/api-server" \
    "$PROXMOX_USER@$PROXMOX_HOST:/tmp/api-server-config"
  
  ssh "$PROXMOX_USER@$PROXMOX_HOST" "pct push $VMID /tmp/api-server-config /usr/local/bin/explorer-config-api && \
    pct exec $VMID -- chmod +x /usr/local/bin/explorer-config-api"
  log_ok "API server copied to VMID $VMID:/usr/local/bin/explorer-config-api"
  
  # Create systemd service
  log_info "Creating systemd service for config API..."
  ssh "$PROXMOX_USER@$PROXMOX_HOST" "pct exec $VMID -- bash -c 'cat > /etc/systemd/system/explorer-config-api.service <<EOF
[Unit]
Description=Explorer Config API (MetaMask networks and token list)
After=network.target postgresql.service

[Service]
Type=simple
User=root
WorkingDirectory=/opt/explorer
Environment=\"PORT=8081\"
Environment=\"CHAIN_ID=138\"
Environment=\"DATABASE_URL=postgresql://explorer:explorer@localhost:5432/explorer_db\"
ExecStart=/usr/local/bin/explorer-config-api
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF
'"
  
  ssh "$PROXMOX_USER@$PROXMOX_HOST" "pct exec $VMID -- systemctl daemon-reload && \
    pct exec $VMID -- systemctl enable explorer-config-api && \
    pct exec $VMID -- systemctl start explorer-config-api"
  
  sleep 3
  if ssh "$PROXMOX_USER@$PROXMOX_HOST" "pct exec $VMID -- systemctl is-active explorer-config-api" | grep -q "active"; then
    log_ok "Config API service started on port 8081"
  else
    log_warn "Config API service may not be running; check logs: journalctl -u explorer-config-api -n 50"
  fi
  
  # Update nginx to proxy /api/config
  log_info "Updating nginx config for /api/config proxy..."
  ssh "$PROXMOX_USER@$PROXMOX_HOST" "pct exec $VMID -- bash -c '
    NGINX_CONF=\$(find /etc/nginx/sites-enabled -name \"*blockscout*\" -o -name \"default\" | head -1)
    if [ -z \"\$NGINX_CONF\" ]; then NGINX_CONF=\"/etc/nginx/sites-enabled/default\"; fi
    
    # Add /api/config location if not present
    if ! grep -q \"location /api/config\" \"\$NGINX_CONF\"; then
      sed -i \"/server_name.*explorer.d-bis.org/a\\
    # MetaMask config API\\
    location /api/config/ {\\
        proxy_pass http://127.0.0.1:8081/api/config/;\\
        proxy_set_header Host \\\$host;\\
        proxy_set_header X-Real-IP \\\$remote_addr;\\
        add_header Access-Control-Allow-Origin \"*\" always;\\
        add_header Cache-Control \"public, max-age=3600\";\\
    }\" \"\$NGINX_CONF\"
      nginx -t && systemctl reload nginx
      echo \"Nginx updated and reloaded\"
    else
      echo \"/api/config already configured\"
    fi
  '"
  
  log_ok "Phase 1 complete: Backend API deployed"
  echo ""
}

# Phase 2: Deploy frontend with Wallet page
deploy_frontend() {
  log_info "========================================="
  log_info "PHASE 2: Deploy frontend (Wallet page)"
  log_info "========================================="
  
  # Build frontend with production env
  log_info "Building frontend for production..."
  (cd "$REPO_ROOT/explorer-monorepo/frontend" && \
    echo "NEXT_PUBLIC_API_URL=https://explorer.d-bis.org" > .env.production && \
    echo "NEXT_PUBLIC_CHAIN_ID=138" >> .env.production && \
    pnpm run build)
  log_ok "Frontend built"
  
  # Create deployment tarball
  log_info "Creating deployment package..."
  (cd "$REPO_ROOT/explorer-monorepo/frontend" && \
    tar czf /tmp/explorer-frontend.tar.gz .next public src package.json next.config.js)
  
  # Copy to VMID 5000
  log_info "Copying frontend to VMID $VMID..."
  scp -o ConnectTimeout=10 /tmp/explorer-frontend.tar.gz \
    "$PROXMOX_USER@$PROXMOX_HOST:/tmp/explorer-frontend.tar.gz"
  
  ssh "$PROXMOX_USER@$PROXMOX_HOST" "pct push $VMID /tmp/explorer-frontend.tar.gz /tmp/explorer-frontend.tar.gz && \
    pct exec $VMID -- bash -c '
      mkdir -p /opt/explorer-frontend
      cd /opt/explorer-frontend
      tar xzf /tmp/explorer-frontend.tar.gz
      rm /tmp/explorer-frontend.tar.gz
      
      # Install deps if needed
      if ! command -v node &>/dev/null; then
        curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
        apt-get install -y nodejs
      fi
      
      # Install pnpm if needed
      if ! command -v pnpm &>/dev/null; then
        npm install -g pnpm@10
      fi
      
      # Install production deps
      pnpm install --prod
    '"
  
  # Create systemd service for Next.js
  log_info "Creating Next.js systemd service..."
  ssh "$PROXMOX_USER@$PROXMOX_HOST" "pct exec $VMID -- bash -c 'cat > /etc/systemd/system/explorer-frontend.service <<EOF
[Unit]
Description=Explorer Frontend (Next.js)
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/explorer-frontend
Environment=\"NODE_ENV=production\"
Environment=\"PORT=3000\"
ExecStart=/usr/bin/pnpm start
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF
'"
  
  ssh "$PROXMOX_USER@$PROXMOX_HOST" "pct exec $VMID -- systemctl daemon-reload && \
    pct exec $VMID -- systemctl enable explorer-frontend && \
    pct exec $VMID -- systemctl restart explorer-frontend"
  
  sleep 3
  if ssh "$PROXMOX_USER@$PROXMOX_HOST" "pct exec $VMID -- systemctl is-active explorer-frontend" | grep -q "active"; then
    log_ok "Frontend service started on port 3000"
  else
    log_warn "Frontend service may not be running; check logs: journalctl -u explorer-frontend -n 50"
  fi
  
  # Update nginx to proxy frontend routes
  log_info "Updating nginx for frontend routes..."
  ssh "$PROXMOX_USER@$PROXMOX_HOST" "pct exec $VMID -- bash -c '
    NGINX_CONF=\$(find /etc/nginx/sites-enabled -name \"*blockscout*\" -o -name \"default\" | head -1)
    if [ -z \"\$NGINX_CONF\" ]; then NGINX_CONF=\"/etc/nginx/sites-enabled/default\"; fi
    
    # Add /wallet and /_next proxies if not present
    if ! grep -q \"location /wallet\" \"\$NGINX_CONF\"; then
      sed -i \"/location \\/api\\/config/a\\
    # Frontend routes (Next.js)\\
    location /wallet {\\
        proxy_pass http://127.0.0.1:3000;\\
        proxy_set_header Host \\\$host;\\
        proxy_set_header X-Real-IP \\\$remote_addr;\\
    }\\
    location /_next/ {\\
        proxy_pass http://127.0.0.1:3000;\\
        proxy_set_header Host \\\$host;\\
    }\" \"\$NGINX_CONF\"
      nginx -t && systemctl reload nginx
      echo \"Nginx updated for frontend\"
    else
      echo \"/wallet already configured\"
    fi
  '"
  
  log_ok "Phase 2 complete: Frontend deployed"
  echo ""
}

# Phase 3: Verify integration
verify_integration() {
  log_info "========================================="
  log_info "PHASE 3: Verify integration"
  log_info "========================================="
  
  # Test config endpoints
  log_info "Testing /api/config/networks..."
  if curl -sf --max-time 10 "https://explorer.d-bis.org/api/config/networks" | grep -q "chains"; then
    log_ok "GET /api/config/networks OK"
  else
    log_fail "GET /api/config/networks failed"
  fi
  
  log_info "Testing /api/config/token-list..."
  if curl -sf --max-time 10 "https://explorer.d-bis.org/api/config/token-list" | grep -q "tokens"; then
    log_ok "GET /api/config/token-list OK"
  else
    log_fail "GET /api/config/token-list failed"
  fi
  
  log_info "Testing /wallet page..."
  if curl -sf --max-time 10 "https://explorer.d-bis.org/wallet" | grep -q "MetaMask"; then
    log_ok "GET /wallet OK"
  else
    log_warn "GET /wallet may not be serving (check Next.js service)"
  fi
  
  # Run full integration script
  log_info "Running full integration script..."
  (cd "$REPO_ROOT/metamask-integration" && \
    EXPLORER_API_URL=https://explorer.d-bis.org ./scripts/integration-test-all.sh)
  
  log_ok "Phase 3 complete: Integration verified"
  echo ""
}

# Phase 4: Optional enhancements
deploy_optional() {
  log_info "========================================="
  log_info "PHASE 4: Optional enhancements"
  log_info "========================================="
  
  log_info "Token-aggregation service deployment (optional):"
  log_info "  - Requires DB and env configuration"
  log_info "  - See: smom-dbis-138/services/token-aggregation/docs/DEPLOYMENT.md"
  log_info "  - Skip for now (can deploy separately)"
  
  log_info "Chain 138 Snap deployment (optional):"
  log_info "  - Run: cd metamask-integration/chain138-snap && pnpm run start"
  log_info "  - Install in MetaMask Flask via http://localhost:8000"
  log_info "  - Skip for now (manual testing)"
  
  log_ok "Phase 4 noted: Optional items documented"
  echo ""
}

# Main execution
main() {
  log_info "Deploying MetaMask integration to explorer.d-bis.org (VMID $VMID)"
  echo ""
  
  check_access
  echo ""
  
  deploy_backend_api
  deploy_frontend
  verify_integration
  deploy_optional
  
  log_ok "========================================="
  log_ok "All phases complete"
  log_ok "========================================="
  echo ""
  echo "Next steps:"
  echo "  1. Visit https://explorer.d-bis.org/wallet to test Add to MetaMask"
  echo "  2. Add token list URL in MetaMask: https://explorer.d-bis.org/api/config/token-list"
  echo "  3. Test adding Chain 138, Ethereum Mainnet, ALL Mainnet"
  echo ""
}

main "$@"
