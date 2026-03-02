#!/bin/bash

# Deploy Blockscout Explorer for ChainID 138 with MetaMask integration
# This script creates deployment configuration and setup instructions

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
log_info "Blockscout Deployment Configuration"
log_info "========================================="
log_info ""

# Create deployment directory
DEPLOY_DIR="$PROJECT_ROOT/blockscout-deployment"
mkdir -p "$DEPLOY_DIR"

# Create Docker Compose configuration
log_info "Creating Docker Compose configuration..."
cat > "$DEPLOY_DIR/docker-compose.yml" << 'EOF'
version: "3.8"

services:
  blockscout-db:
    image: postgres:15
    container_name: blockscout-db
    environment:
      - POSTGRES_USER=blockscout
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-blockscout}
      - POSTGRES_DB=blockscout
    volumes:
      - blockscout-db-data:/var/lib/postgresql/data
    networks:
      - blockscout-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U blockscout"]
      interval: 10s
      timeout: 5s
      retries: 5

  blockscout:
    image: blockscout/blockscout:latest
    container_name: blockscout
    depends_on:
      blockscout-db:
        condition: service_healthy
    environment:
      # Database
      - DATABASE_URL=postgresql://blockscout:${POSTGRES_PASSWORD:-blockscout}@blockscout-db:5432/blockscout
      
      # Network
      - ETHEREUM_JSONRPC_HTTP_URL=http://192.168.11.211:8545
      - ETHEREUM_JSONRPC_WS_URL=ws://192.168.11.211:8546
      - ETHEREUM_JSONRPC_TRACE_URL=http://192.168.11.211:8545
      
      # Chain Configuration
      - COIN=ETH
      - NETWORK=DeFi Oracle Meta Mainnet
      - SUBNETWORK=Mainnet
      - BLOCK_TRANSFORMER=base
      - CHAIN_ID=138
      
      # Features
      - SHOW_ADDRESS_MARKETCAP_PERCENTAGE=true
      - ENABLE_ACCOUNT_BALANCE_CACHE=true
      - ENABLE_EXCHANGE_RATES=true
      - EXCHANGE_RATES_COINGECKO_COIN_ID=ethereum
      - ENABLE_SOURCIFY_INTEGRATION=true
      - SOURCIFY_SERVER_URL=https://sourcify.dev/server
      - ENABLE_TXS_STATS=true
      - TXS_STATS_DAYS_TO_COMPILE_AT_INIT=1
      
      # MetaMask Portfolio CORS Configuration
      - ENABLE_CORS=true
      - CORS_ALLOWED_ORIGINS=https://portfolio.metamask.io,https://metamask.io,https://chainlist.org,https://explorer.d-bis.org
      - CORS_ALLOWED_METHODS=GET,POST,OPTIONS
      - CORS_ALLOWED_HEADERS=Content-Type,Authorization,Accept
      - CORS_MAX_AGE=3600
      
      # Token Metadata API
      - ENABLE_TOKEN_METADATA_API=true
      - TOKEN_METADATA_CACHE_ENABLED=true
      - TOKEN_METADATA_CACHE_TTL=3600
      
      # Logo Serving
      - ENABLE_TOKEN_LOGO_SERVING=true
      - TOKEN_LOGO_BASE_URL=https://explorer.d-bis.org/images/tokens
      
      # API Rate Limiting
      - API_RATE_LIMIT_ENABLED=true
      - API_RATE_LIMIT_PER_MINUTE=120
      
      # Security
      - SECRET_KEY_BASE=${SECRET_KEY_BASE:-change-me-in-production-use-openssl-rand-hex-32}
      
    ports:
      - "4000:4000"
    networks:
      - blockscout-network
    restart: unless-stopped
    volumes:
      - blockscout-logs:/var/log/blockscout
      - blockscout-static:/var/www/blockscout/priv/static

volumes:
  blockscout-db-data:
  blockscout-logs:
  blockscout-static:

networks:
  blockscout-network:
    driver: bridge
EOF

log_success "Created: $DEPLOY_DIR/docker-compose.yml"

# Create Kubernetes deployment
log_info "Creating Kubernetes deployment configuration..."
cat > "$DEPLOY_DIR/blockscout-deployment.yaml" << 'EOF'
apiVersion: v1
kind: Namespace
metadata:
  name: blockscout
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: blockscout-config
  namespace: blockscout
data:
  # Database
  DATABASE_URL: "postgresql://blockscout:blockscout@blockscout-db:5432/blockscout"
  
  # Network
  ETHEREUM_JSONRPC_HTTP_URL: "http://192.168.11.211:8545"
  ETHEREUM_JSONRPC_WS_URL: "ws://192.168.11.211:8546"
  ETHEREUM_JSONRPC_TRACE_URL: "http://192.168.11.211:8545"
  
  # Chain Configuration
  COIN: "ETH"
  NETWORK: "DeFi Oracle Meta Mainnet"
  SUBNETWORK: "Mainnet"
  BLOCK_TRANSFORMER: "base"
  CHAIN_ID: "138"
  
  # MetaMask Portfolio CORS
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
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: blockscout
  namespace: blockscout
spec:
  replicas: 1
  selector:
    matchLabels:
      app: blockscout
  template:
    metadata:
      labels:
        app: blockscout
    spec:
      containers:
      - name: blockscout
        image: blockscout/blockscout:latest
        ports:
        - containerPort: 4000
        envFrom:
        - configMapRef:
            name: blockscout-config
        env:
        - name: SECRET_KEY_BASE
          valueFrom:
            secretKeyRef:
              name: blockscout-secrets
              key: secret-key-base
        volumeMounts:
        - name: blockscout-static
          mountPath: /var/www/blockscout/priv/static
      volumes:
      - name: blockscout-static
        persistentVolumeClaim:
          claimName: blockscout-static-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: blockscout
  namespace: blockscout
spec:
  selector:
    app: blockscout
  ports:
  - port: 80
    targetPort: 4000
  type: LoadBalancer
EOF

log_success "Created: $DEPLOY_DIR/blockscout-deployment.yaml"

# Create deployment checklist
cat > "$DEPLOY_DIR/DEPLOYMENT_CHECKLIST.md" << 'EOF'
# Blockscout Deployment Checklist

## Pre-Deployment

- [ ] Server/Cluster is provisioned
- [ ] Docker/Kubernetes is installed
- [ ] Database is ready
- [ ] RPC endpoints are accessible
- [ ] DNS is configured
- [ ] SSL certificates are ready

## Deployment Steps

### Docker Compose Deployment

1. **Prepare Environment**:
   ```bash
   cd blockscout-deployment
   cp .env.example .env
   # Edit .env with your values
   ```

2. **Generate Secret Key**:
   ```bash
   SECRET_KEY_BASE=$(openssl rand -hex 32)
   echo "SECRET_KEY_BASE=$SECRET_KEY_BASE" >> .env
   ```

3. **Start Services**:
   ```bash
   docker-compose up -d
   ```

4. **Verify Deployment**:
   ```bash
   docker-compose ps
   docker-compose logs blockscout
   ```

5. **Access Blockscout**:
   - URL: http://localhost:4000
   - Or via nginx reverse proxy

### Kubernetes Deployment

1. **Create Namespace**:
   ```bash
   kubectl apply -f blockscout-deployment.yaml
   ```

2. **Create Secrets**:
   ```bash
   kubectl create secret generic blockscout-secrets \
     --from-literal=secret-key-base=$(openssl rand -hex 32) \
     -n blockscout
   ```

3. **Verify Deployment**:
   ```bash
   kubectl get pods -n blockscout
   kubectl get services -n blockscout
   ```

4. **Check Logs**:
   ```bash
   kubectl logs -f deployment/blockscout -n blockscout
   ```

## Post-Deployment

- [ ] Blockscout is accessible
- [ ] CORS headers are configured
- [ ] Token metadata API works
- [ ] Logo serving works
- [ ] Explorer shows transactions
- [ ] API endpoints are accessible
- [ ] Portfolio integration tested

## Verification

### Test Blockscout

```bash
# Test Blockscout is running
curl http://localhost:4000/api/v2/health

# Test CORS headers
curl -I -X OPTIONS http://localhost:4000/api/v2/tokens/0x... \
  -H "Origin: https://portfolio.metamask.io" \
  -H "Access-Control-Request-Method: GET"

# Test token metadata API
curl http://localhost:4000/api/v2/tokens/0x93E66202A11B1772E55407B32B44e5Cd8eda7f22
```

### Expected Results

- ✅ Blockscout is accessible
- ✅ CORS headers are present
- ✅ Token metadata API returns data
- ✅ Logo URLs are accessible
- ✅ Transactions are visible

## Troubleshooting

### Blockscout Not Starting

1. Check database connection
2. Check RPC endpoint accessibility
3. Check logs: `docker-compose logs blockscout`
4. Verify environment variables
5. Check resource limits

### CORS Not Working

1. Verify CORS environment variables
2. Check nginx configuration (if using reverse proxy)
3. Test CORS headers
4. Verify allowed origins

### API Not Working

1. Check API endpoints are enabled
2. Verify database is populated
3. Check API logs
4. Test API endpoints directly

---

**Last Updated**: 2026-01-26
EOF

log_success "Created: $DEPLOY_DIR/DEPLOYMENT_CHECKLIST.md"

log_info ""
log_info "========================================="
log_info "Blockscout Deployment Config Complete!"
log_info "========================================="
log_info ""
log_info "Files created in: $DEPLOY_DIR"
log_info "  - docker-compose.yml (Docker deployment)"
log_info "  - blockscout-deployment.yaml (Kubernetes deployment)"
log_info "  - DEPLOYMENT_CHECKLIST.md (deployment guide)"
log_info ""
log_info "Next steps:"
log_info "1. Review deployment files"
log_info "2. Configure environment variables"
log_info "3. Deploy Blockscout"
log_info "4. Verify CORS configuration"
log_info "5. Test Portfolio integration"
log_info ""
