# MetaMask Integration - Complete Deployment Requirements

**Date**: 2026-01-26  
**Purpose**: Comprehensive list of all requirements for deploying MetaMask integration infrastructure

---

## 📋 Table of Contents

1. [Infrastructure Requirements](#infrastructure-requirements)
2. [Software Requirements](#software-requirements)
3. [Network Requirements](#network-requirements)
4. [Security Requirements](#security-requirements)
5. [DNS & SSL Requirements](#dns--ssl-requirements)
6. [Database Requirements](#database-requirements)
7. [Storage Requirements](#storage-requirements)
8. [Access & Permissions](#access--permissions)
9. [External Service Requirements](#external-service-requirements)
10. [Configuration Requirements](#configuration-requirements)

---

## 🖥️ Infrastructure Requirements

### Server/Compute Resources

#### RPC Endpoint Servers
- **Minimum**: 2 servers (primary + secondary)
- **CPU**: 4+ cores per server
- **RAM**: 8GB+ per server
- **Storage**: 50GB+ SSD per server
- **Network**: 1Gbps+ connection
- **OS**: Linux (Ubuntu 20.04+ or similar)

#### Blockscout Explorer Server
- **CPU**: 4+ cores
- **RAM**: 8GB+ (16GB recommended)
- **Storage**: 100GB+ SSD
- **Network**: 1Gbps+ connection
- **OS**: Linux (Ubuntu 20.04+ or similar)

#### Load Balancer/Gateway (Optional)
- **Azure Application Gateway** (if using Azure)
- **Nginx** (if using self-hosted)
- **Cloudflare** (for DNS and DDoS protection)

### Container Orchestration (Optional)

#### Docker
- **Docker Engine**: 20.10+
- **Docker Compose**: 2.0+

#### Kubernetes (Optional)
- **Kubernetes**: 1.24+
- **kubectl**: Latest
- **Helm**: 3.0+ (if using Helm charts)

---

## 💻 Software Requirements

### System Software

#### Required
- **Nginx**: 1.18+ (for reverse proxy)
- **PostgreSQL**: 13+ (for Blockscout database)
- **OpenSSL**: Latest (for SSL certificate management)
- **curl**: Latest (for testing)
- **jq**: Latest (for JSON processing)
- **bash**: 4.4+ (for scripts)

#### Optional
- **certbot**: Latest (for Let's Encrypt certificates)
- **Docker**: 20.10+ (for containerized deployment)
- **Terraform**: 1.0+ (for Azure Gateway deployment)
- **Azure CLI**: Latest (for Azure deployments)

### Development Tools (For Testing)

- **Node.js**: 18+ (for running examples)
- **npm/pnpm**: Latest
- **MetaMask Extension**: Latest
- **Web Browser**: Chrome/Firefox/Edge (latest)

---

## 🌐 Network Requirements

### Network Configuration

#### RPC Endpoints
- **Primary RPC**: `rpc.d-bis.org` → Server IP
- **Secondary RPC**: `rpc2.d-bis.org` → Server IP
- **Internal RPC**: `192.168.11.211:8545` (backend)
- **Protocol**: HTTPS (443) and HTTP (80 for redirect)

#### Explorer
- **Explorer URL**: `explorer.d-bis.org` → Server IP
- **Protocol**: HTTPS (443) and HTTP (80 for redirect)
- **Port**: 4000 (Blockscout default)

#### Firewall Rules

**Inbound**:
- Port 80 (HTTP) - Allow from Cloudflare IPs only
- Port 443 (HTTPS) - Allow from Cloudflare IPs only
- Port 8545 (RPC) - Allow from internal network only
- Port 4000 (Blockscout) - Allow from internal network only

**Outbound**:
- Port 443 (HTTPS) - Allow all (for external API calls)
- Port 80 (HTTP) - Allow all (for external API calls)
- Port 5432 (PostgreSQL) - Allow from internal network only

### Network Connectivity

- **Internet Access**: Required for all servers
- **Internal Network**: Required for RPC backend access
- **DNS Resolution**: Required for domain names
- **SSL/TLS**: Required for HTTPS endpoints

---

## 🔒 Security Requirements

### SSL/TLS Certificates

#### Option 1: Cloudflare SSL (Recommended)
- **Cloudflare Account**: Required
- **Domain**: `d-bis.org` added to Cloudflare
- **SSL Mode**: Full (strict)
- **Auto-renewal**: Automatic

#### Option 2: Let's Encrypt
- **certbot**: Installed
- **Domain Validation**: DNS or HTTP validation
- **Certificate Files**: 
  - `/etc/letsencrypt/live/rpc.d-bis.org/fullchain.pem`
  - `/etc/letsencrypt/live/rpc.d-bis.org/privkey.pem`
- **Auto-renewal**: Systemd timer configured

#### Option 3: Custom Certificate
- **Certificate**: PFX or PEM format
- **Private Key**: Securely stored
- **Certificate Chain**: Full chain included
- **Validity**: Not expired

### Security Headers

- **CORS Headers**: Configured for MetaMask domains
- **HSTS**: Enabled
- **X-Frame-Options**: Configured
- **X-Content-Type-Options**: Configured
- **Rate Limiting**: Configured

### Access Control

- **SSH Keys**: Configured (no password auth)
- **Firewall**: Configured (UFW/iptables)
- **User Permissions**: Least privilege
- **Secret Management**: Secure storage for passwords/keys

---

## 🌍 DNS & SSL Requirements

### DNS Configuration

#### Required DNS Records

1. **Primary RPC**:
   - Type: A
   - Name: `rpc`
   - Value: Server IP address
   - TTL: 300 (or Auto)
   - Proxy: Enabled (Cloudflare)

2. **Secondary RPC**:
   - Type: A
   - Name: `rpc2`
   - Value: Server IP address
   - TTL: 300 (or Auto)
   - Proxy: Enabled (Cloudflare)

3. **Explorer**:
   - Type: A
   - Name: `explorer`
   - Value: Server IP address
   - TTL: 300 (or Auto)
   - Proxy: Enabled (Cloudflare)

4. **RPC Core Alias** (Optional):
   - Type: CNAME
   - Name: `rpc-core`
   - Value: `rpc.d-bis.org`
   - TTL: 300 (or Auto)
   - Proxy: Enabled (Cloudflare)

#### DNS Provider Requirements

- **Cloudflare Account**: Required
- **Domain**: `d-bis.org` registered
- **Nameservers**: Updated to Cloudflare
- **DNS API Access**: For automated configuration (optional)

### SSL/TLS Requirements

- **HTTPS**: Required for all public endpoints
- **TLS Version**: 1.2 minimum, 1.3 preferred
- **Certificate Validity**: Not expired
- **Certificate Chain**: Complete chain
- **Auto-renewal**: Configured

---

## 🗄️ Database Requirements

### PostgreSQL Database (For Blockscout)

#### Minimum Requirements
- **Version**: PostgreSQL 13+
- **Storage**: 50GB+ (grows with chain data)
- **RAM**: 4GB+ allocated
- **CPU**: 2+ cores
- **Connections**: 100+ max connections

#### Database Configuration
- **Database Name**: `blockscout`
- **User**: `blockscout`
- **Password**: Secure password (stored securely)
- **Encoding**: UTF-8
- **Extensions**: Required extensions installed

#### Backup Requirements
- **Backup Strategy**: Daily backups
- **Retention**: 30+ days
- **Recovery**: Tested recovery procedure

---

## 💾 Storage Requirements

### Blockscout Storage

- **Database**: 50GB+ (grows with chain data)
- **Logs**: 10GB+ (rotated)
- **Static Files**: 5GB+ (token logos, images)
- **Total**: 100GB+ recommended

### RPC Server Storage

- **Logs**: 10GB+ (rotated)
- **Configuration**: 1GB
- **Total**: 20GB+ recommended

### Token Logo Storage

- **Logo Files**: 1GB+ (PNG files, multiple sizes)
- **CDN**: Optional (for better performance)

---

## 🔑 Access & Permissions

### Server Access

- **SSH Access**: Required
- **Root/Sudo Access**: Required for deployment
- **User Account**: Non-root user with sudo
- **SSH Keys**: Configured

### Cloudflare Access

- **Account**: Cloudflare account
- **API Token**: For automated DNS configuration (optional)
- **Zone ID**: For API operations (optional)

### Azure Access (If Using Azure Gateway)

- **Azure Subscription**: Required
- **Azure CLI**: Installed and authenticated
- **Terraform**: Installed (for infrastructure as code)
- **Resource Group**: Created or existing
- **Permissions**: Contributor or Owner role

### Database Access

- **PostgreSQL Access**: Local or network access
- **Database Credentials**: Secure storage
- **Connection String**: Configured

---

## 🌐 External Service Requirements

### Required Services

#### Cloudflare
- **Account**: Free tier or higher
- **Domain**: `d-bis.org` added
- **DNS**: Configured
- **SSL/TLS**: Enabled

#### RPC Backend
- **Besu Node**: Running at `192.168.11.211:8545`
- **WebSocket**: Available at `192.168.11.211:8546`
- **Accessibility**: Network accessible

### Optional Services

#### GitHub (For Token List Hosting)
- **GitHub Account**: Required
- **Repository**: Created or existing
- **GitHub Pages**: Enabled

#### IPFS (For Token List Hosting)
- **IPFS Node**: Running (optional)
- **Pinning Service**: Pinata/Infura (optional)

#### Monitoring Services
- **Uptime Monitoring**: UptimeRobot/Pingdom (optional)
- **Error Tracking**: Sentry (optional)
- **Analytics**: Google Analytics (optional)

---

## ⚙️ Configuration Requirements

### Environment Variables

#### Blockscout Environment Variables
```bash
DATABASE_URL=postgresql://blockscout:password@localhost:5432/blockscout
ETHEREUM_JSONRPC_HTTP_URL=http://192.168.11.211:8545
ETHEREUM_JSONRPC_WS_URL=ws://192.168.11.211:8546
CHAIN_ID=138
SECRET_KEY_BASE=<generated-secret>
CORS_ALLOWED_ORIGINS=https://portfolio.metamask.io,https://metamask.io
ENABLE_CORS=true
```

#### Nginx Configuration
- **Config File**: `/etc/nginx/sites-available/rpc.d-bis.org`
- **SSL Certificates**: Configured
- **CORS Headers**: Configured
- **Rate Limiting**: Configured

### Configuration Files

#### Required Files
- `nginx-rpc.conf` - Nginx RPC configuration
- `docker-compose.yml` - Blockscout Docker Compose
- `blockscout-deployment.yaml` - Kubernetes deployment (if using K8s)
- `.env` - Environment variables (secure)

#### Optional Files
- `terraform/main.tf` - Azure Gateway Terraform config
- `cloudflare-dns-config.json` - DNS records config

---

## 📦 Application Requirements

### Blockscout

- **Image**: `blockscout/blockscout:latest`
- **Version**: Latest stable
- **Port**: 4000
- **Health Check**: `/api/v2/health`
- **Database**: PostgreSQL 13+

### RPC Backend

- **Besu Node**: Running and accessible
- **RPC Port**: 8545
- **WebSocket Port**: 8546
- **Network**: ChainID 138

---

## 🔧 Deployment Tools

### Required Tools

- **bash**: 4.4+ (for deployment scripts)
- **git**: Latest (for version control)
- **curl**: Latest (for API testing)
- **jq**: Latest (for JSON processing)

### Optional Tools

- **Docker**: 20.10+ (for containerized deployment)
- **Docker Compose**: 2.0+ (for multi-container setup)
- **kubectl**: Latest (for Kubernetes deployment)
- **Terraform**: 1.0+ (for infrastructure as code)
- **Azure CLI**: Latest (for Azure deployments)

---

## ✅ Pre-Deployment Checklist

### Infrastructure
- [ ] Servers provisioned and accessible
- [ ] Network connectivity verified
- [ ] Firewall rules configured
- [ ] DNS records configured
- [ ] SSL certificates obtained

### Software
- [ ] Required software installed
- [ ] Docker/Kubernetes configured (if using)
- [ ] Database server running
- [ ] Nginx installed and configured

### Security
- [ ] SSH keys configured
- [ ] Firewall rules applied
- [ ] SSL certificates installed
- [ ] Security headers configured
- [ ] Secrets stored securely

### Configuration
- [ ] Environment variables set
- [ ] Configuration files created
- [ ] Database initialized
- [ ] CORS headers configured

### Testing
- [ ] RPC endpoints tested
- [ ] Explorer tested
- [ ] SSL certificates verified
- [ ] CORS headers verified
- [ ] MetaMask connection tested

---

## 📊 Resource Summary

### Minimum Requirements (Small Deployment)

- **Servers**: 2 (RPC + Explorer)
- **Total CPU**: 8 cores
- **Total RAM**: 16GB
- **Total Storage**: 150GB
- **Network**: 1Gbps

### Recommended Requirements (Production)

- **Servers**: 3+ (RPC Primary, RPC Secondary, Explorer)
- **Total CPU**: 16+ cores
- **Total RAM**: 32GB+
- **Total Storage**: 500GB+
- **Network**: 10Gbps
- **Load Balancer**: Yes
- **Backup**: Automated

---

## 🚀 Deployment Order

1. **Infrastructure Setup**
   - Provision servers
   - Configure network
   - Set up firewall

2. **DNS Configuration**
   - Add DNS records
   - Configure Cloudflare
   - Verify DNS resolution

3. **SSL Certificate Setup**
   - Obtain certificates
   - Install certificates
   - Configure auto-renewal

4. **Database Setup**
   - Install PostgreSQL
   - Create database
   - Configure access

5. **RPC Deployment**
   - Configure nginx
   - Deploy RPC proxy
   - Test endpoints

6. **Blockscout Deployment**
   - Deploy Blockscout
   - Configure CORS
   - Test explorer

7. **Token List Hosting**
   - Choose hosting method
   - Deploy token list
   - Test accessibility

8. **Verification**
   - Test all endpoints
   - Verify CORS headers
   - Test MetaMask connection
   - Monitor performance

---

## 📝 Notes

- All requirements assume Linux-based deployment
- Windows deployment possible but not documented
- Cloud-specific requirements (Azure, AWS, GCP) may vary
- Some requirements are optional depending on deployment method
- All scripts and configurations are provided in the repository

---

**Last Updated**: 2026-01-26
