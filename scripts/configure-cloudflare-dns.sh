#!/bin/bash

# Configure Cloudflare DNS for ChainID 138 MetaMask Integration
# This script creates DNS configuration files and instructions

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
log_info "Cloudflare DNS Configuration"
log_info "========================================="
log_info ""

# Create DNS configuration directory
DNS_DIR="$PROJECT_ROOT/cloudflare-dns-config"
mkdir -p "$DNS_DIR"

# Create DNS records configuration
log_info "Creating DNS records configuration..."
cat > "$DNS_DIR/dns-records.json" << 'EOF'
{
  "records": [
    {
      "type": "A",
      "name": "rpc",
      "content": "<server-ip-address>",
      "ttl": 300,
      "proxied": true,
      "comment": "Primary RPC endpoint for ChainID 138"
    },
    {
      "type": "A",
      "name": "rpc2",
      "content": "<server-ip-address>",
      "ttl": 300,
      "proxied": true,
      "comment": "Secondary RPC endpoint for ChainID 138"
    },
    {
      "type": "A",
      "name": "explorer",
      "content": "<server-ip-address>",
      "ttl": 300,
      "proxied": true,
      "comment": "Blockscout explorer for ChainID 138"
    },
    {
      "type": "CNAME",
      "name": "rpc-core",
      "content": "rpc.d-bis.org",
      "ttl": 300,
      "proxied": true,
      "comment": "RPC core endpoint alias"
    }
  ]
}
EOF

log_success "Created: $DNS_DIR/dns-records.json"

# Create Cloudflare API script
log_info "Creating Cloudflare API configuration script..."
cat > "$DNS_DIR/configure-dns-api.sh" << 'EOF'
#!/bin/bash

# Configure Cloudflare DNS via API
# Requires: CLOUDFLARE_API_TOKEN and CLOUDFLARE_ZONE_ID

set -e

ZONE_ID="${CLOUDFLARE_ZONE_ID}"
API_TOKEN="${CLOUDFLARE_API_TOKEN}"
DOMAIN="d-bis.org"

if [ -z "$ZONE_ID" ] || [ -z "$API_TOKEN" ]; then
    echo "Error: CLOUDFLARE_ZONE_ID and CLOUDFLARE_API_TOKEN must be set"
    exit 1
fi

# Function to create DNS record
create_record() {
    local type=$1
    local name=$2
    local content=$3
    local proxied=${4:-true}
    
    curl -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
        -H "Authorization: Bearer $API_TOKEN" \
        -H "Content-Type: application/json" \
        --data "{
            \"type\": \"$type\",
            \"name\": \"$name\",
            \"content\": \"$content\",
            \"ttl\": 300,
            \"proxied\": $proxied
        }"
}

# Create RPC endpoint
echo "Creating rpc.d-bis.org..."
create_record "A" "rpc" "<server-ip>" true

# Create secondary RPC endpoint
echo "Creating rpc2.d-bis.org..."
create_record "A" "rpc2" "<server-ip>" true

# Create explorer endpoint
echo "Creating explorer.d-bis.org..."
create_record "A" "explorer" "<server-ip>" true

echo "DNS records created successfully!"
EOF

chmod +x "$DNS_DIR/configure-dns-api.sh"
log_success "Created: $DNS_DIR/configure-dns-api.sh"

# Create manual configuration guide
cat > "$DNS_DIR/MANUAL_CONFIGURATION.md" << 'EOF'
# Cloudflare DNS Manual Configuration Guide

## Prerequisites

1. Cloudflare account
2. Domain `d-bis.org` added to Cloudflare
3. Access to Cloudflare dashboard

## DNS Records to Create

### 1. Primary RPC Endpoint (rpc.d-bis.org)

**Type**: A  
**Name**: `rpc`  
**IPv4 address**: `<your-server-ip>`  
**Proxy status**: Proxied (orange cloud)  
**TTL**: Auto  

**Purpose**: Primary RPC endpoint for ChainID 138

---

### 2. Secondary RPC Endpoint (rpc2.d-bis.org)

**Type**: A  
**Name**: `rpc2`  
**IPv4 address**: `<your-server-ip>`  
**Proxy status**: Proxied (orange cloud)  
**TTL**: Auto  

**Purpose**: Secondary RPC endpoint for redundancy

---

### 3. Explorer Endpoint (explorer.d-bis.org)

**Type**: A  
**Name**: `explorer`  
**IPv4 address**: `<your-server-ip>`  
**Proxy status**: Proxied (orange cloud)  
**TTL**: Auto  

**Purpose**: Blockscout explorer for ChainID 138

---

### 4. RPC Core Alias (rpc-core.d-bis.org)

**Type**: CNAME  
**Name**: `rpc-core`  
**Target**: `rpc.d-bis.org`  
**Proxy status**: Proxied (orange cloud)  
**TTL**: Auto  

**Purpose**: Alias for primary RPC endpoint

---

## Configuration Steps

### Step 1: Access Cloudflare Dashboard

1. Go to https://dash.cloudflare.com
2. Select your account
3. Select domain `d-bis.org`

### Step 2: Navigate to DNS

1. Click "DNS" in the left sidebar
2. Click "Records"
3. Click "Add record"

### Step 3: Create Records

For each record above:
1. Select record type
2. Enter name
3. Enter content (IP address or target)
4. Enable proxy (orange cloud)
5. Click "Save"

### Step 4: Verify Records

1. Check all records are created
2. Verify proxy status is enabled
3. Verify TTL is set correctly
4. Test DNS resolution

---

## DNS Verification

### Test DNS Resolution

```bash
# Test primary RPC
dig rpc.d-bis.org +short

# Test secondary RPC
dig rpc2.d-bis.org +short

# Test explorer
dig explorer.d-bis.org +short

# Test RPC core alias
dig rpc-core.d-bis.org +short
```

### Expected Results

All should resolve to your server IP address (or Cloudflare proxy IPs if proxied).

---

## SSL/TLS Configuration

### Automatic SSL

Cloudflare provides automatic SSL certificates:
1. Go to SSL/TLS settings
2. Set encryption mode to "Full" or "Full (strict)"
3. Enable "Always Use HTTPS"
4. SSL certificates are automatically provisioned

### SSL Verification

```bash
# Test SSL certificate
openssl s_client -connect rpc.d-bis.org:443 -servername rpc.d-bis.org

# Check certificate validity
echo | openssl s_client -connect rpc.d-bis.org:443 2>/dev/null | openssl x509 -noout -dates
```

---

## Proxy Configuration

### Benefits of Proxying

- DDoS protection
- CDN caching
- SSL termination
- IP hiding

### Considerations

- Proxy adds latency (~10-50ms)
- Some features may require direct IP access
- RPC endpoints may need direct access

### Configuration

For RPC endpoints, you may want to:
1. Start with proxy enabled
2. Monitor performance
3. Disable proxy if needed for low latency

---

## Page Rules

### Recommended Page Rules

1. **Cache Level**: Standard
2. **Browser Cache TTL**: 4 hours
3. **Edge Cache TTL**: 2 hours

### Create Page Rule

1. Go to Rules → Page Rules
2. Click "Create Page Rule"
3. URL pattern: `rpc.d-bis.org/*`
4. Settings:
   - Cache Level: Standard
   - Browser Cache TTL: 4 hours
   - Edge Cache TTL: 2 hours

---

## Security Settings

### Recommended Settings

1. **Security Level**: Medium
2. **Challenge Passage**: 30 minutes
3. **Browser Integrity Check**: On
4. **Privacy Pass Support**: On

### Rate Limiting

Create rate limiting rules:
- Rate: 10 requests per second per IP
- Burst: 20 requests
- Action: Challenge or Block

---

## Monitoring

### Cloudflare Analytics

1. Monitor DNS queries
2. Monitor traffic
3. Monitor errors
4. Monitor performance

### Alerts

Set up alerts for:
- High error rates
- DDoS attacks
- SSL certificate expiration
- DNS resolution issues

---

## Troubleshooting

### DNS Not Resolving

1. Check DNS records are correct
2. Check proxy status
3. Wait for DNS propagation (up to 48 hours)
4. Clear DNS cache

### SSL Certificate Issues

1. Check SSL/TLS mode is "Full"
2. Verify origin server has valid certificate
3. Check certificate expiration
4. Review SSL errors in Cloudflare dashboard

### Performance Issues

1. Check proxy status
2. Review Cloudflare analytics
3. Check origin server performance
4. Consider disabling proxy for RPC endpoints

---

## Next Steps

After DNS configuration:

1. ✅ Verify DNS resolution
2. ✅ Configure SSL certificates
3. ✅ Test RPC endpoints
4. ✅ Test explorer
5. ✅ Update MetaMask network config
6. ✅ Update token lists

---

**Last Updated**: 2026-01-26
EOF

log_success "Created: $DNS_DIR/MANUAL_CONFIGURATION.md"

log_info ""
log_info "========================================="
log_info "DNS Configuration Complete!"
log_info "========================================="
log_info ""
log_info "Files created in: $DNS_DIR"
log_info "  - dns-records.json (DNS records config)"
log_info "  - configure-dns-api.sh (API script)"
log_info "  - MANUAL_CONFIGURATION.md (manual guide)"
log_info ""
log_info "Next steps:"
log_info "1. Review DNS configuration"
log_info "2. Configure Cloudflare DNS"
log_info "3. Verify DNS resolution"
log_info "4. Configure SSL certificates"
log_info ""
