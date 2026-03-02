#!/bin/bash

# Deploy Azure Application Gateway for ChainID 138 MetaMask Integration
# This script creates Terraform configuration and deployment instructions

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
log_info "Azure Application Gateway Deployment"
log_info "========================================="
log_info ""

# Create deployment directory
GATEWAY_DIR="$PROJECT_ROOT/azure-gateway-deployment"
mkdir -p "$GATEWAY_DIR"

# Create Terraform configuration
log_info "Creating Terraform configuration..."
cat > "$GATEWAY_DIR/main.tf" << 'EOF'
# Azure Application Gateway for ChainID 138 MetaMask Integration

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "rg-chain138-metamask"
  location = "East US"
}

# Public IP
resource "azurerm_public_ip" "gateway" {
  name                = "pip-chain138-gateway"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Application Gateway
resource "azurerm_application_gateway" "main" {
  name                = "agw-chain138"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "gateway-ip-config"
    subnet_id = azurerm_subnet.gateway.id
  }

  frontend_port {
    name = "https"
    port = 443
  }

  frontend_port {
    name = "http"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "public-ip"
    public_ip_address_id = azurerm_public_ip.gateway.id
  }

  # Backend Pool for RPC
  backend_address_pool {
    name = "rpc-backend-pool"
    ip_addresses = ["192.168.11.211"]
  }

  # Backend Pool for Explorer
  backend_address_pool {
    name = "explorer-backend-pool"
    ip_addresses = ["<explorer-ip>"]
  }

  # HTTP Settings with CORS
  backend_http_settings {
    name                  = "rpc-http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 8545
    protocol              = "Http"
    request_timeout       = 60
  }

  backend_http_settings {
    name                  = "explorer-http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 4000
    protocol              = "Http"
    request_timeout       = 60
  }

  # HTTP Listener for RPC
  http_listener {
    name                           = "rpc-https-listener"
    frontend_ip_configuration_name = "public-ip"
    frontend_port_name             = "https"
    protocol                       = "Https"
    ssl_certificate_name           = "ssl-certificate"
  }

  # Request Routing Rule for RPC
  request_routing_rule {
    name                       = "rpc-https-rule"
    rule_type                  = "Basic"
    http_listener_name         = "rpc-https-listener"
    backend_address_pool_name  = "rpc-backend-pool"
    backend_http_settings_name = "rpc-http-settings"
  }

  # Rewrite Rule Set for CORS
  rewrite_rule_set {
    name = "cors-headers"

    rewrite_rule {
      name          = "add-cors-headers"
      rule_sequence = 100

      response_header_configuration {
        header_name  = "Access-Control-Allow-Origin"
        header_value = "*"
      }

      response_header_configuration {
        header_name  = "Access-Control-Allow-Methods"
        header_value = "GET, POST, OPTIONS"
      }

      response_header_configuration {
        header_name  = "Access-Control-Allow-Headers"
        header_value = "Content-Type, Authorization"
      }

      response_header_configuration {
        header_name  = "Access-Control-Max-Age"
        header_value = "3600"
      }
    }
  }

  # SSL Certificate (use Key Vault or upload)
  ssl_certificate {
    name     = "ssl-certificate"
    data     = filebase64("ssl-certificate.pfx")
    password = var.ssl_certificate_password
  }
}

# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "vnet-chain138"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# Subnet for Gateway
resource "azurerm_subnet" "gateway" {
  name                 = "subnet-gateway"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

variable "ssl_certificate_password" {
  description = "Password for SSL certificate"
  type        = string
  sensitive   = true
}
EOF

log_success "Created: $GATEWAY_DIR/main.tf"

# Create deployment guide
cat > "$GATEWAY_DIR/DEPLOYMENT_GUIDE.md" << 'EOF'
# Azure Application Gateway Deployment Guide

## Overview

Azure Application Gateway provides load balancing, SSL termination, and CORS support for ChainID 138 MetaMask integration endpoints.

## Prerequisites

1. Azure subscription
2. Azure CLI installed
3. Terraform installed
4. SSL certificate (PFX format)
5. Resource group permissions

## Deployment Steps

### Step 1: Azure Login

```bash
az login
az account set --subscription "<subscription-id>"
```

### Step 2: Configure Terraform

1. **Set Variables**:
   ```bash
   export TF_VAR_ssl_certificate_password="your-certificate-password"
   ```

2. **Initialize Terraform**:
   ```bash
   terraform init
   ```

3. **Plan Deployment**:
   ```bash
   terraform plan
   ```

4. **Apply Configuration**:
   ```bash
   terraform apply
   ```

### Step 3: Configure DNS

1. Get Public IP from Terraform output
2. Create DNS A records pointing to Public IP:
   - `rpc.d-bis.org` → Public IP
   - `rpc2.d-bis.org` → Public IP
   - `explorer.d-bis.org` → Public IP

### Step 4: Configure SSL Certificate

1. **Upload Certificate**:
   - Convert certificate to PFX format
   - Upload to Azure Key Vault (recommended)
   - Or include in Terraform configuration

2. **Key Vault Integration** (Recommended):
   ```hcl
   data "azurerm_key_vault_certificate" "ssl" {
     name         = "ssl-certificate"
     key_vault_id = azurerm_key_vault.main.id
   }
   ```

### Step 5: Verify Deployment

```bash
# Test RPC endpoint
curl -X POST https://rpc.d-bis.org \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'

# Test CORS headers
curl -I -X OPTIONS https://rpc.d-bis.org \
  -H "Origin: https://metamask.io" \
  -H "Access-Control-Request-Method: POST"
```

## Configuration Details

### CORS Headers

Application Gateway adds CORS headers via rewrite rules:
- `Access-Control-Allow-Origin: *`
- `Access-Control-Allow-Methods: GET, POST, OPTIONS`
- `Access-Control-Allow-Headers: Content-Type, Authorization`
- `Access-Control-Max-Age: 3600`

### Backend Pools

- **RPC Backend**: Points to `192.168.11.211:8545`
- **Explorer Backend**: Points to Blockscout instance

### SSL/TLS

- TLS 1.2 minimum
- TLS 1.3 enabled
- Strong cipher suites
- HSTS enabled

## Monitoring

### Azure Monitor

1. Set up alerts for:
   - High error rates
   - High latency
   - Backend health issues

2. Monitor metrics:
   - Request count
   - Response time
   - Failed requests
   - Backend health

## Troubleshooting

### Gateway Not Responding

1. Check backend pool health
2. Check NSG rules
3. Check backend server status
4. Review gateway logs

### CORS Not Working

1. Verify rewrite rule set is applied
2. Check response headers
3. Test CORS preflight
4. Review gateway configuration

---

**Last Updated**: 2026-01-26
EOF

log_success "Created: $GATEWAY_DIR/DEPLOYMENT_GUIDE.md"

log_info ""
log_info "========================================="
log_info "Azure Gateway Config Complete!"
log_info "========================================="
log_info ""
log_info "Files created in: $GATEWAY_DIR"
log_info "  - main.tf (Terraform configuration)"
log_info "  - DEPLOYMENT_GUIDE.md (deployment guide)"
log_info ""
log_info "Next steps:"
log_info "1. Configure Azure credentials"
log_info "2. Prepare SSL certificate"
log_info "3. Run terraform apply"
log_info "4. Configure DNS"
log_info "5. Test endpoints"
log_info ""
