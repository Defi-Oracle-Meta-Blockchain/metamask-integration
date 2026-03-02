# SSL Certificate Setup Guide

Complete guide for configuring SSL certificates for ChainID 138 MetaMask integration endpoints.

## Overview

SSL certificates are required for HTTPS endpoints (RPC, explorer) to ensure secure connections from MetaMask.

## Options

### Option 1: Cloudflare SSL (Recommended)

**Benefits**:
- Free SSL certificates
- Automatic provisioning
- Auto-renewal
- DDoS protection included

**Setup**:
1. Enable Cloudflare proxy (orange cloud)
2. Set SSL/TLS mode to "Full" or "Full (strict)"
3. SSL certificates are automatically provisioned
4. Certificates auto-renew

**Configuration**:
- Go to Cloudflare Dashboard → SSL/TLS
- Set encryption mode: "Full (strict)"
- Enable "Always Use HTTPS"
- Enable "Automatic HTTPS Rewrites"

---

### Option 2: Let's Encrypt

**Benefits**:
- Free SSL certificates
- Widely trusted
- 90-day validity

**Setup**:
```bash
# Install certbot
sudo apt-get update
sudo apt-get install certbot

# Obtain certificate for RPC endpoint
sudo certbot certonly --standalone -d rpc.d-bis.org

# Obtain certificate for explorer
sudo certbot certonly --standalone -d explorer.d-bis.org

# Auto-renewal setup
sudo certbot renew --dry-run
```

**Nginx Configuration**:
```nginx
server {
    listen 443 ssl http2;
    server_name rpc.d-bis.org;

    ssl_certificate /etc/letsencrypt/live/rpc.d-bis.org/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/rpc.d-bis.org/privkey.pem;
    
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    
    # ... rest of configuration
}
```

---

### Option 3: Custom SSL Certificate

**Use Case**: Enterprise or custom requirements

**Providers**:
- DigiCert
- GlobalSign
- Sectigo
- GoDaddy

**Setup**:
1. Purchase SSL certificate
2. Generate CSR (Certificate Signing Request)
3. Submit CSR to provider
4. Install certificate
5. Configure web server

---

## Cloudflare SSL Configuration

### Step 1: Enable SSL/TLS

1. Go to Cloudflare Dashboard
2. Select domain `d-bis.org`
3. Go to SSL/TLS
4. Set encryption mode to "Full (strict)"

### Step 2: Configure SSL Settings

**SSL/TLS encryption mode**: Full (strict)

**Always Use HTTPS**: On

**Automatic HTTPS Rewrites**: On

**Minimum TLS Version**: TLS 1.2

**Opportunistic Encryption**: On

**TLS 1.3**: On

### Step 3: Verify SSL

```bash
# Test SSL certificate
openssl s_client -connect rpc.d-bis.org:443 -servername rpc.d-bis.org

# Check certificate details
echo | openssl s_client -connect rpc.d-bis.org:443 2>/dev/null | openssl x509 -noout -text
```

---

## Let's Encrypt Setup

### Automated Setup Script

```bash
#!/bin/bash
# Automated Let's Encrypt SSL setup for ChainID 138 endpoints

DOMAINS=(
    "rpc.d-bis.org"
    "rpc2.d-bis.org"
    "explorer.d-bis.org"
)

EMAIL="admin@d-bis.org"

# Install certbot
sudo apt-get update
sudo apt-get install -y certbot

# Obtain certificates
for domain in "${DOMAINS[@]}"; do
    echo "Obtaining certificate for $domain..."
    sudo certbot certonly \
        --standalone \
        --non-interactive \
        --agree-tos \
        --email "$EMAIL" \
        -d "$domain"
done

# Setup auto-renewal
sudo systemctl enable certbot.timer
sudo systemctl start certbot.timer

echo "SSL certificates obtained and auto-renewal configured!"
```

### Nginx SSL Configuration

```nginx
# SSL Configuration for RPC endpoint
server {
    listen 443 ssl http2;
    server_name rpc.d-bis.org;

    # SSL Certificate
    ssl_certificate /etc/letsencrypt/live/rpc.d-bis.org/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/rpc.d-bis.org/privkey.pem;

    # SSL Protocols
    ssl_protocols TLSv1.2 TLSv1.3;

    # SSL Ciphers
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384';
    ssl_prefer_server_ciphers on;

    # SSL Session
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    # Security Headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;

    # ... rest of configuration
}

# HTTP to HTTPS redirect
server {
    listen 80;
    server_name rpc.d-bis.org;
    return 301 https://$server_name$request_uri;
}
```

---

## Certificate Verification

### Test SSL Certificate

```bash
# Test certificate validity
openssl s_client -connect rpc.d-bis.org:443 -servername rpc.d-bis.org < /dev/null

# Check certificate expiration
echo | openssl s_client -connect rpc.d-bis.org:443 2>/dev/null | openssl x509 -noout -dates

# Check certificate chain
openssl s_client -connect rpc.d-bis.org:443 -showcerts

# Test from browser
curl -vI https://rpc.d-bis.org
```

### Expected Results

- ✅ Certificate is valid
- ✅ Certificate chain is complete
- ✅ Certificate matches domain
- ✅ Certificate is not expired
- ✅ HTTPS redirect works

---

## Auto-Renewal

### Let's Encrypt Auto-Renewal

```bash
# Test renewal
sudo certbot renew --dry-run

# Enable auto-renewal (systemd timer)
sudo systemctl enable certbot.timer
sudo systemctl start certbot.timer

# Check timer status
sudo systemctl status certbot.timer
```

### Cloudflare Auto-Renewal

Cloudflare automatically renews certificates. No action needed.

---

## Troubleshooting

### Certificate Not Working

1. Check certificate is installed correctly
2. Verify certificate matches domain
3. Check certificate expiration
4. Verify web server configuration
5. Check firewall rules

### Mixed Content Warnings

1. Ensure all resources use HTTPS
2. Update HTTP links to HTTPS
3. Use relative URLs where possible
4. Enable HSTS header

### Certificate Chain Issues

1. Verify intermediate certificates are included
2. Check certificate chain is complete
3. Test with SSL Labs: https://www.ssllabs.com/ssltest/

---

## Security Best Practices

1. **Use Strong Ciphers**: Only TLS 1.2 and 1.3
2. **Enable HSTS**: Strict Transport Security
3. **Regular Updates**: Keep certificates updated
4. **Monitor Expiration**: Set up expiration alerts
5. **Use Full Chain**: Include intermediate certificates

---

## Checklist

- [ ] SSL certificate obtained
- [ ] Certificate installed on server
- [ ] Web server configured for SSL
- [ ] HTTPS redirect configured
- [ ] Certificate verified
- [ ] Auto-renewal configured
- [ ] Security headers configured
- [ ] HSTS enabled
- [ ] Certificate tested from browser
- [ ] Certificate tested from MetaMask

---

**Last Updated**: 2026-01-26
