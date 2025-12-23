#!/bin/bash
# Script to create a Proxmox API token via the Proxmox API
# 
# Usage:
#   ./create-proxmox-token.sh <proxmox-host> <username> <password> <token-name>
#
# Example:
#   ./create-proxmox-token.sh 192.168.1.100 root@pam mypassword mcp-server
#
# Note: This requires valid Proxmox credentials and uses the Proxmox API v2

set -e

PROXMOX_HOST="${1:-}"
USERNAME="${2:-}"
PASSWORD="${3:-}"
TOKEN_NAME="${4:-mcp-server}"
PROXMOX_PORT="${PROXMOX_PORT:-8006}"

if [ -z "$PROXMOX_HOST" ] || [ -z "$USERNAME" ] || [ -z "$PASSWORD" ]; then
    echo "Usage: $0 <proxmox-host> <username> <password> [token-name]"
    echo ""
    echo "Example:"
    echo "  $0 192.168.1.100 root@pam mypassword mcp-server"
    echo ""
    echo "Environment variables:"
    echo "  PROXMOX_PORT - Proxmox port (default: 8006)"
    exit 1
fi

echo "Creating Proxmox API token..."
echo "Host: $PROXMOX_HOST:$PROXMOX_PORT"
echo "User: $USERNAME"
echo "Token Name: $TOKEN_NAME"
echo ""

# Step 1: Get CSRF token and ticket by authenticating
echo "Authenticating..."
AUTH_RESPONSE=$(curl -s -k -d "username=$USERNAME&password=$PASSWORD" \
    "https://${PROXMOX_HOST}:${PROXMOX_PORT}/api2/json/access/ticket")

if echo "$AUTH_RESPONSE" | grep -q "data"; then
    TICKET=$(echo "$AUTH_RESPONSE" | grep -oP '"ticket":"\K[^"]+')
    CSRF_TOKEN=$(echo "$AUTH_RESPONSE" | grep -oP '"CSRFPreventionToken":"\K[^"]+')
    
    if [ -z "$TICKET" ] || [ -z "$CSRF_TOKEN" ]; then
        echo "Error: Failed to authenticate. Check credentials."
        echo "Response: $AUTH_RESPONSE"
        exit 1
    fi
    
    echo "✓ Authentication successful"
else
    echo "Error: Authentication failed"
    echo "Response: $AUTH_RESPONSE"
    exit 1
fi

# Step 2: Create API token
echo "Creating API token..."
TOKEN_RESPONSE=$(curl -s -k -X POST \
    -H "Cookie: PVEAuthCookie=$TICKET" \
    -H "CSRFPreventionToken: $CSRF_TOKEN" \
    -d "tokenid=${USERNAME}!${TOKEN_NAME}" \
    "https://${PROXMOX_HOST}:${PROXMOX_PORT}/api2/json/access/users/${USERNAME}/token/${TOKEN_NAME}")

if echo "$TOKEN_RESPONSE" | grep -q "data"; then
    TOKEN_VALUE=$(echo "$TOKEN_RESPONSE" | grep -oP '"value":"\K[^"]+')
    
    if [ -z "$TOKEN_VALUE" ]; then
        echo "Error: Token created but could not extract value"
        echo "Response: $TOKEN_RESPONSE"
        exit 1
    fi
    
    echo ""
    echo "✅ API Token created successfully!"
    echo ""
    echo "Add these to your ~/.env file:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "PROXMOX_HOST=$PROXMOX_HOST"
    echo "PROXMOX_USER=$USERNAME"
    echo "PROXMOX_TOKEN_NAME=$TOKEN_NAME"
    echo "PROXMOX_TOKEN_VALUE=$TOKEN_VALUE"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "⚠️  IMPORTANT: Save the PROXMOX_TOKEN_VALUE immediately!"
    echo "   This is the only time it will be displayed."
    echo ""
else
    echo "Error: Failed to create token"
    echo "Response: $TOKEN_RESPONSE"
    exit 1
fi

