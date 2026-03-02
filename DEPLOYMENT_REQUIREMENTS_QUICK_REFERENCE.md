# Deployment Requirements - Quick Reference

**Quick checklist of all deployment requirements**

---

## 🖥️ Infrastructure

### Servers
- [ ] **RPC Servers**: 2+ (4 CPU, 8GB RAM, 50GB storage each)
- [ ] **Blockscout Server**: 1 (4 CPU, 16GB RAM, 100GB storage)
- [ ] **Load Balancer**: Optional (Nginx or Azure Gateway)

### Network
- [ ] **Public IPs**: For RPC and Explorer endpoints
- [ ] **Internal Network**: Access to Besu node (192.168.11.211:8545)
- [ ] **Firewall**: Ports 80, 443 open (from Cloudflare)

---

## 💻 Software

### Required
- [ ] **Nginx**: 1.18+ (reverse proxy)
- [ ] **PostgreSQL**: 13+ (Blockscout database)
- [ ] **Docker**: 20.10+ (optional, for containerized deployment)
- [ ] **OpenSSL**: Latest
- [ ] **bash**: 4.4+
- [ ] **curl, jq**: Latest

### Optional
- [ ] **certbot**: For Let's Encrypt
- [ ] **Terraform**: For Azure Gateway
- [ ] **kubectl**: For Kubernetes

---

## 🌐 DNS & SSL

### DNS Records (Cloudflare)
- [ ] **rpc.d-bis.org** → Server IP (A record, proxied)
- [ ] **rpc2.d-bis.org** → Server IP (A record, proxied)
- [ ] **explorer.d-bis.org** → Server IP (A record, proxied)

### SSL Certificates
- [ ] **Option 1**: Cloudflare SSL (automatic, recommended)
- [ ] **Option 2**: Let's Encrypt (certbot)
- [ ] **Option 3**: Custom certificate (PFX/PEM)

---

## 🗄️ Database

### PostgreSQL
- [ ] **Version**: 13+
- [ ] **Storage**: 50GB+ (grows with chain data)
- [ ] **Database**: `blockscout`
- [ ] **User**: `blockscout`
- [ ] **Password**: Secure password

---

## 🔑 Access & Credentials

### Required Access
- [ ] **SSH**: Server access with sudo
- [ ] **Cloudflare**: Account with domain `d-bis.org`
- [ ] **Database**: PostgreSQL access
- [ ] **RPC Backend**: Network access to 192.168.11.211:8545

### Optional Access
- [ ] **Azure**: Subscription (if using Azure Gateway)
- [ ] **GitHub**: Account (for token list hosting)
- [ ] **IPFS**: Node or pinning service (optional)

---

## ⚙️ Configuration

### Environment Variables
- [ ] **DATABASE_URL**: PostgreSQL connection string
- [ ] **ETHEREUM_JSONRPC_HTTP_URL**: http://192.168.11.211:8545
- [ ] **ETHEREUM_JSONRPC_WS_URL**: ws://192.168.11.211:8546
- [ ] **CHAIN_ID**: 138
- [ ] **SECRET_KEY_BASE**: Generated secret (for Blockscout)
- [ ] **CORS_ALLOWED_ORIGINS**: MetaMask domains

### Configuration Files
- [ ] **nginx-rpc.conf**: Nginx RPC configuration
- [ ] **docker-compose.yml**: Blockscout Docker Compose
- [ ] **.env**: Environment variables (secure)

---

## 📦 Applications

### Blockscout
- [ ] **Image**: `blockscout/blockscout:latest`
- [ ] **Port**: 4000
- [ ] **CORS**: Enabled for MetaMask domains
- [ ] **Token Metadata API**: Enabled

### RPC Backend
- [ ] **Besu Node**: Running at 192.168.11.211:8545
- [ ] **WebSocket**: Available at 192.168.11.211:8546
- [ ] **Network**: ChainID 138

---

## 🔒 Security

### SSL/TLS
- [ ] **HTTPS**: Enabled for all endpoints
- [ ] **TLS**: 1.2 minimum, 1.3 preferred
- [ ] **Auto-renewal**: Configured

### Security Headers
- [ ] **CORS**: Configured for MetaMask
- [ ] **HSTS**: Enabled
- [ ] **Rate Limiting**: Configured

### Access Control
- [ ] **SSH Keys**: Configured
- [ ] **Firewall**: Configured
- [ ] **Secrets**: Stored securely

---

## 📊 Resource Summary

### Minimum (Small Deployment)
- **Servers**: 2
- **CPU**: 8 cores total
- **RAM**: 16GB total
- **Storage**: 150GB total

### Recommended (Production)
- **Servers**: 3+
- **CPU**: 16+ cores total
- **RAM**: 32GB+ total
- **Storage**: 500GB+ total
- **Load Balancer**: Yes

---

## 🚀 Deployment Order

1. [ ] Provision servers
2. [ ] Configure network & firewall
3. [ ] Set up DNS records
4. [ ] Obtain SSL certificates
5. [ ] Install PostgreSQL
6. [ ] Deploy RPC endpoints
7. [ ] Deploy Blockscout
8. [ ] Configure CORS
9. [ ] Host token list
10. [ ] Test everything

---

## 📝 Quick Commands

### Test RPC
```bash
curl -X POST https://rpc.d-bis.org \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'
```

### Test Explorer
```bash
curl https://explorer.d-bis.org/api/v2/health
```

### Test CORS
```bash
curl -I -X OPTIONS https://explorer.d-bis.org/api/v2/tokens/0x... \
  -H "Origin: https://portfolio.metamask.io"
```

---

**See `DEPLOYMENT_REQUIREMENTS.md` for detailed information**
