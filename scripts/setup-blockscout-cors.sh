#!/bin/bash

# Setup Blockscout CORS Configuration for MetaMask Portfolio
# This script creates CORS configuration files for Blockscout

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
log_info "Blockscout CORS Configuration Setup"
log_info "========================================="
log_info ""

# Create CORS configuration directory
CORS_DIR="$PROJECT_ROOT/blockscout-cors-config"
mkdir -p "$CORS_DIR"

# Create environment variables file
log_info "Creating CORS environment configuration..."
cat > "$CORS_DIR/cors.env" << 'EOF'
# Blockscout CORS Configuration for MetaMask Portfolio
# Add these environment variables to your Blockscout deployment

# Enable CORS
ENABLE_CORS=true

# Allowed Origins (comma-separated)
CORS_ALLOWED_ORIGINS=https://portfolio.metamask.io,https://metamask.io,https://chainlist.org,https://explorer.d-bis.org

# CORS Allowed Methods
CORS_ALLOWED_METHODS=GET,POST,OPTIONS

# CORS Allowed Headers
CORS_ALLOWED_HEADERS=Content-Type,Authorization,Accept

# CORS Max Age (seconds)
CORS_MAX_AGE=3600

# Token Metadata API Configuration
ENABLE_TOKEN_METADATA_API=true
TOKEN_METADATA_CACHE_ENABLED=true
TOKEN_METADATA_CACHE_TTL=3600

# Logo Serving Configuration
ENABLE_TOKEN_LOGO_SERVING=true
TOKEN_LOGO_BASE_URL=https://explorer.d-bis.org/images/tokens

# API Rate Limiting
API_RATE_LIMIT_ENABLED=true
API_RATE_LIMIT_PER_MINUTE=120
EOF

log_success "Created: $CORS_DIR/cors.env"

# Create Kubernetes ConfigMap
log_info "Creating Kubernetes ConfigMap..."
cat > "$CORS_DIR/blockscout-cors-configmap.yaml" << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: blockscout-metamask-cors
  namespace: besu-network
  labels:
    app: blockscout
    component: cors-config
data:
  # CORS Configuration
  ENABLE_CORS: "true"
  CORS_ALLOWED_ORIGINS: "https://portfolio.metamask.io,https://metamask.io,https://chainlist.org,https://explorer.d-bis.org"
  CORS_ALLOWED_METHODS: "GET,POST,OPTIONS"
  CORS_ALLOWED_HEADERS: "Content-Type,Authorization,Accept"
  CORS_MAX_AGE: "3600"
  
  # Token Metadata API
  ENABLE_TOKEN_METADATA_API: "true"
  TOKEN_METADATA_CACHE_ENABLED: "true"
  TOKEN_METADATA_CACHE_TTL: "3600"
  
  # Logo Serving
  ENABLE_TOKEN_LOGO_SERVING: "true"
  TOKEN_LOGO_BASE_URL: "https://explorer.d-bis.org/images/tokens"
  
  # API Rate Limiting
  API_RATE_LIMIT_ENABLED: "true"
  API_RATE_LIMIT_PER_MINUTE: "120"
EOF

log_success "Created: $CORS_DIR/blockscout-cors-configmap.yaml"

# Create Docker Compose environment
log_info "Creating Docker Compose environment..."
cat > "$CORS_DIR/docker-compose.cors.env" << 'EOF'
# Blockscout CORS Configuration for Docker Compose
# Add to your docker-compose.yml environment section

ENABLE_CORS=true
CORS_ALLOWED_ORIGINS=https://portfolio.metamask.io,https://metamask.io,https://chainlist.org,https://explorer.d-bis.org
CORS_ALLOWED_METHODS=GET,POST,OPTIONS
CORS_ALLOWED_HEADERS=Content-Type,Authorization,Accept
CORS_MAX_AGE=3600
ENABLE_TOKEN_METADATA_API=true
TOKEN_METADATA_CACHE_ENABLED=true
TOKEN_METADATA_CACHE_TTL=3600
ENABLE_TOKEN_LOGO_SERVING=true
TOKEN_LOGO_BASE_URL=https://explorer.d-bis.org/images/tokens
API_RATE_LIMIT_ENABLED=true
API_RATE_LIMIT_PER_MINUTE=120
EOF

log_success "Created: $CORS_DIR/docker-compose.cors.env"

# Create nginx CORS configuration (if using nginx in front of Blockscout)
log_info "Creating nginx CORS configuration..."
cat > "$CORS_DIR/nginx-cors.conf" << 'EOF'
# Nginx CORS Configuration for Blockscout
# Add to your nginx server block for explorer.d-bis.org

# CORS Headers for MetaMask Portfolio
add_header Access-Control-Allow-Origin "https://portfolio.metamask.io" always;
add_header Access-Control-Allow-Methods "GET, POST, OPTIONS" always;
add_header Access-Control-Allow-Headers "Content-Type, Authorization, Accept" always;
add_header Access-Control-Max-Age 3600 always;
add_header Access-Control-Allow-Credentials true always;

# Handle OPTIONS preflight requests
if ($request_method = OPTIONS) {
    add_header Access-Control-Allow-Origin "https://portfolio.metamask.io" always;
    add_header Access-Control-Allow-Methods "GET, POST, OPTIONS" always;
    add_header Access-Control-Allow-Headers "Content-Type, Authorization, Accept" always;
    add_header Access-Control-Max-Age 3600 always;
    add_header Content-Length 0;
    add_header Content-Type text/plain;
    return 204;
}

# Additional CORS for other MetaMask domains
if ($http_origin ~* "^https://(metamask\.io|chainlist\.org)$") {
    add_header Access-Control-Allow-Origin "$http_origin" always;
}
EOF

log_success "Created: $CORS_DIR/nginx-cors.conf"

# Create application configuration
log_info "Creating application configuration..."
cat > "$CORS_DIR/blockscout-config.exs" << 'EOF'
# Blockscout CORS Configuration (Elixir/Phoenix)
# Add to config/prod.exs or config/runtime.exs

config :blockscout_web, BlockscoutWeb.Endpoint,
  http: [
    port: 4000,
    protocol_options: [
      idle_timeout: 60_000
    ]
  ],
  # CORS Configuration
  cors: [
    enabled: true,
    allowed_origins: [
      "https://portfolio.metamask.io",
      "https://metamask.io",
      "https://chainlist.org",
      "https://explorer.d-bis.org"
    ],
    allowed_methods: ["GET", "POST", "OPTIONS"],
    allowed_headers: ["Content-Type", "Authorization", "Accept"],
    max_age: 3600
  ],
  # Token Metadata API
  token_metadata: [
    enabled: true,
    cache_enabled: true,
    cache_ttl: 3600
  ],
  # Logo Serving
  logo_serving: [
    enabled: true,
    base_url: "https://explorer.d-bis.org/images/tokens"
  ],
  # API Rate Limiting
  rate_limiting: [
    enabled: true,
    requests_per_minute: 120
  ]
EOF

log_success "Created: $CORS_DIR/blockscout-config.exs"

# Create setup instructions
cat > "$CORS_DIR/SETUP_INSTRUCTIONS.md" << 'EOF'
# Blockscout CORS Configuration Setup

## Overview

This directory contains CORS configuration files for Blockscout to enable MetaMask Portfolio compatibility.

## Files

- `cors.env` - Environment variables for Blockscout
- `blockscout-cors-configmap.yaml` - Kubernetes ConfigMap
- `docker-compose.cors.env` - Docker Compose environment
- `nginx-cors.conf` - Nginx CORS configuration
- `blockscout-config.exs` - Elixir/Phoenix configuration

## Setup Methods

### Method 1: Environment Variables (Docker/Kubernetes)

1. **Docker Compose**:
   ```bash
   # Add to docker-compose.yml
   env_file:
     - docker-compose.cors.env
   ```

2. **Kubernetes**:
   ```bash
   kubectl apply -f blockscout-cors-configmap.yaml
   # Then reference in deployment:
   envFrom:
     - configMapRef:
         name: blockscout-metamask-cors
   ```

3. **Direct Environment**:
   ```bash
   source cors.env
   # Or export variables manually
   ```

### Method 2: Application Configuration (Elixir)

1. Copy `blockscout-config.exs` to your Blockscout config
2. Merge with existing configuration
3. Restart Blockscout

### Method 3: Nginx (Reverse Proxy)

1. Add `nginx-cors.conf` to your nginx server block
2. Reload nginx: `systemctl reload nginx`

## Verification

Test CORS headers:

```bash
# Test CORS preflight
curl -I -X OPTIONS https://explorer.d-bis.org/api/v2/tokens/0x... \
  -H "Origin: https://portfolio.metamask.io" \
  -H "Access-Control-Request-Method: GET"

# Expected headers:
# Access-Control-Allow-Origin: https://portfolio.metamask.io
# Access-Control-Allow-Methods: GET, POST, OPTIONS
# Access-Control-Allow-Headers: Content-Type, Authorization, Accept
```

## API Endpoints Required

Blockscout must provide these API endpoints for Portfolio:

1. **Token Metadata**:
   ```
   GET /api/v2/tokens/{address}
   ```

2. **Token Holders**:
   ```
   GET /api/v2/tokens/{address}/holders
   ```

3. **Account Token Balances**:
   ```
   GET /api/v2/addresses/{address}/token-balances
   ```

4. **Account Transactions**:
   ```
   GET /api/v2/addresses/{address}/transactions
   ```

## Testing

After configuration:

1. Restart Blockscout
2. Test CORS headers (see verification above)
3. Test from MetaMask Portfolio
4. Verify token metadata is accessible
5. Verify token logos are accessible

## Troubleshooting

### CORS Headers Not Appearing

- Check if CORS is enabled in Blockscout
- Verify environment variables are set
- Check nginx/application logs
- Verify origin is in allowed list

### Portfolio Cannot Access API

- Verify API endpoints are accessible
- Check rate limiting settings
- Verify SSL certificates are valid
- Test API endpoints directly

## Support

For issues, check:
- Blockscout documentation
- MetaMask Portfolio requirements
- CORS configuration best practices
EOF

log_success "Created: $CORS_DIR/SETUP_INSTRUCTIONS.md"

log_info ""
log_info "========================================="
log_info "CORS Configuration Complete!"
log_info "========================================="
log_info ""
log_info "Files created in: $CORS_DIR"
log_info ""
log_info "Next steps:"
log_info "1. Review SETUP_INSTRUCTIONS.md"
log_info "2. Apply CORS configuration to Blockscout"
log_info "3. Test CORS headers"
log_info "4. Verify Portfolio compatibility"
log_info ""
