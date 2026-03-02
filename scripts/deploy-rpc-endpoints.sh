#!/bin/bash

# Deploy Production RPC Endpoints for ChainID 138
# This script helps configure and deploy RPC endpoints

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

log_info "========================================="
log_info "RPC Endpoint Deployment Guide"
log_info "========================================="
log_info ""

# RPC Configuration
PRIMARY_RPC="https://rpc.d-bis.org"
SECONDARY_RPC="https://rpc2.d-bis.org"
INTERNAL_RPC="http://192.168.11.211:8545"

log_info "RPC Endpoint Configuration:"
log_info "  Primary: $PRIMARY_RPC"
log_info "  Secondary: $SECONDARY_RPC"
log_info "  Internal: $INTERNAL_RPC"
log_info ""

# Create deployment directory
DEPLOY_DIR="$PROJECT_ROOT/rpc-deployment"
mkdir -p "$DEPLOY_DIR"

# Create nginx configuration for RPC
log_info "Creating nginx configuration..."
cat > "$DEPLOY_DIR/nginx-rpc.conf" << 'EOF'
# Nginx configuration for RPC endpoints
# This config provides HTTPS, CORS, and rate limiting for RPC endpoints

upstream besu_rpc {
    server 192.168.11.211:8545;
    keepalive 32;
}

server {
    listen 443 ssl http2;
    server_name rpc.d-bis.org;

    # SSL Configuration
    ssl_certificate /etc/ssl/certs/d-bis.org.crt;
    ssl_certificate_key /etc/ssl/private/d-bis.org.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    # CORS Headers for MetaMask
    add_header Access-Control-Allow-Origin * always;
    add_header Access-Control-Allow-Methods "GET, POST, OPTIONS" always;
    add_header Access-Control-Allow-Headers "Content-Type, Authorization" always;
    add_header Access-Control-Max-Age 3600 always;

    # Handle OPTIONS requests
    if ($request_method = OPTIONS) {
        return 204;
    }

    # Rate Limiting
    limit_req_zone $binary_remote_addr zone=rpc_limit:10m rate=10r/s;
    limit_req zone=rpc_limit burst=20 nodelay;

    # RPC Endpoint
    location / {
        proxy_pass http://besu_rpc;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Health Check
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
}

# Secondary RPC endpoint
server {
    listen 443 ssl http2;
    server_name rpc2.d-bis.org;

    # SSL Configuration (same as primary)
    ssl_certificate /etc/ssl/certs/d-bis.org.crt;
    ssl_certificate_key /etc/ssl/private/d-bis.org.key;
    ssl_protocols TLSv1.2 TLSv1.3;

    # CORS Headers
    add_header Access-Control-Allow-Origin * always;
    add_header Access-Control-Allow-Methods "GET, POST, OPTIONS" always;
    add_header Access-Control-Allow-Headers "Content-Type, Authorization" always;

    # Rate Limiting
    limit_req_zone $binary_remote_addr zone=rpc_limit:10m rate=10r/s;
    limit_req zone=rpc_limit burst=20 nodelay;

    location / {
        proxy_pass http://besu_rpc;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

# HTTP to HTTPS redirect
server {
    listen 80;
    server_name rpc.d-bis.org rpc2.d-bis.org;
    return 301 https://$server_name$request_uri;
}
EOF

log_success "Created: $DEPLOY_DIR/nginx-rpc.conf"

# Create Cloudflare configuration
log_info "Creating Cloudflare configuration..."
cat > "$DEPLOY_DIR/cloudflare-dns-config.md" << 'EOF'
# Cloudflare DNS Configuration for RPC Endpoints

## DNS Records Required

### Primary RPC Endpoint (rpc.d-bis.org)

**A Record**:
- Name: `rpc`
- Type: `A`
- Content: `<server-ip-address>`
- TTL: `Auto` or `300`
- Proxy: `Proxied` (for DDoS protection)

**AAAA Record** (if IPv6 available):
- Name: `rpc`
- Type: `AAAA`
- Content: `<server-ipv6-address>`
- TTL: `Auto` or `300`
- Proxy: `Proxied`

### Secondary RPC Endpoint (rpc2.d-bis.org)

**A Record**:
- Name: `rpc2`
- Type: `A`
- Content: `<server-ip-address>`
- TTL: `Auto` or `300`
- Proxy: `Proxied`

**AAAA Record** (if IPv6 available):
- Name: `rpc2`
- Type: `AAAA`
- Content: `<server-ipv6-address>`
- TTL: `Auto` or `300`
- Proxy: `Proxied`

## SSL/TLS Configuration

1. **Enable SSL/TLS**:
   - Go to Cloudflare Dashboard → SSL/TLS
   - Set encryption mode to "Full" or "Full (strict)"
   - Enable "Always Use HTTPS"

2. **SSL Certificate**:
   - Cloudflare provides free SSL certificates
   - Automatic certificate provisioning
   - Certificate auto-renewal

3. **Minimum TLS Version**:
   - Set to TLS 1.2 minimum
   - Recommended: TLS 1.3

## Page Rules

Create page rules for optimal performance:

1. **Cache Level**: Standard
2. **Browser Cache TTL**: 4 hours
3. **Edge Cache TTL**: 2 hours

## Security Settings

1. **Security Level**: Medium
2. **Challenge Passage**: 30 minutes
3. **Browser Integrity Check**: On
4. **Privacy Pass Support**: On

## Rate Limiting

Configure rate limiting rules:
- Rate: 10 requests per second per IP
- Burst: 20 requests
- Action: Challenge or Block

## Monitoring

Set up Cloudflare Analytics:
- Monitor RPC endpoint traffic
- Track error rates
- Monitor response times
EOF

log_success "Created: $DEPLOY_DIR/cloudflare-dns-config.md"

# Create deployment checklist
cat > "$DEPLOY_DIR/DEPLOYMENT_CHECKLIST.md" << 'EOF'
# RPC Endpoint Deployment Checklist

## Pre-Deployment

- [ ] Server is provisioned and accessible
- [ ] Nginx is installed and configured
- [ ] SSL certificates are obtained
- [ ] DNS records are configured
- [ ] Firewall rules are configured
- [ ] Monitoring is set up

## Deployment Steps

1. **Configure Nginx**:
   - [ ] Copy nginx-rpc.conf to /etc/nginx/sites-available/
   - [ ] Create symlink to sites-enabled
   - [ ] Test configuration: `nginx -t`
   - [ ] Reload nginx: `systemctl reload nginx`

2. **Configure SSL**:
   - [ ] Install SSL certificates
   - [ ] Verify certificate validity
   - [ ] Test HTTPS connection
   - [ ] Verify certificate auto-renewal

3. **Configure DNS**:
   - [ ] Add A records for rpc.d-bis.org
   - [ ] Add A records for rpc2.d-bis.org
   - [ ] Verify DNS propagation
   - [ ] Test DNS resolution

4. **Configure Cloudflare**:
   - [ ] Add domain to Cloudflare
   - [ ] Update nameservers
   - [ ] Configure SSL/TLS
   - [ ] Enable proxy
   - [ ] Configure page rules

5. **Test Endpoints**:
   - [ ] Test primary RPC: `curl https://rpc.d-bis.org`
   - [ ] Test secondary RPC: `curl https://rpc2.d-bis.org`
   - [ ] Test CORS headers
   - [ ] Test rate limiting
   - [ ] Test from MetaMask

6. **Monitor**:
   - [ ] Set up monitoring alerts
   - [ ] Configure logging
   - [ ] Test health checks
   - [ ] Monitor performance

## Post-Deployment

- [ ] Update MetaMask network config with new RPC URLs
- [ ] Update token lists with new RPC URLs
- [ ] Test MetaMask connection
- [ ] Document RPC endpoints
- [ ] Announce RPC endpoints

## Verification

Test RPC endpoints:

```bash
# Test primary RPC
curl -X POST https://rpc.d-bis.org \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'

# Test secondary RPC
curl -X POST https://rpc2.d-bis.org \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'

# Test CORS
curl -I -X OPTIONS https://rpc.d-bis.org \
  -H "Origin: https://metamask.io" \
  -H "Access-Control-Request-Method: POST"
```

Expected CORS headers:
- `Access-Control-Allow-Origin: *`
- `Access-Control-Allow-Methods: GET, POST, OPTIONS`
- `Access-Control-Allow-Headers: Content-Type, Authorization`
EOF

log_success "Created: $DEPLOY_DIR/DEPLOYMENT_CHECKLIST.md"

log_info ""
log_info "========================================="
log_info "RPC Deployment Guide Complete!"
log_info "========================================="
log_info ""
log_info "Files created in: $DEPLOY_DIR"
log_info "  - nginx-rpc.conf (nginx configuration)"
log_info "  - cloudflare-dns-config.md (DNS setup)"
log_info "  - DEPLOYMENT_CHECKLIST.md (deployment steps)"
log_info ""
log_info "Next steps:"
log_info "1. Review deployment files"
log_info "2. Follow DEPLOYMENT_CHECKLIST.md"
log_info "3. Deploy RPC endpoints"
log_info ""
