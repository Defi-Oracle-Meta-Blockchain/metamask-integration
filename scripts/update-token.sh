#!/bin/bash
# Script to update PROXMOX_TOKEN_VALUE in .env file

ENV_FILE="$HOME/.env"

if [ ! -f "$ENV_FILE" ]; then
    echo "❌ .env file not found at $ENV_FILE"
    exit 1
fi

echo "🔐 Update Proxmox API Token"
echo "============================"
echo ""
echo "Please paste the token secret you copied from Proxmox UI:"
echo "(The secret will be hidden as you type)"
echo ""
read -s TOKEN_VALUE

if [ -z "$TOKEN_VALUE" ]; then
    echo "❌ No token value provided"
    exit 1
fi

# Update the .env file
if grep -q "^PROXMOX_TOKEN_VALUE=" "$ENV_FILE"; then
    # Use sed to update the line (works with special characters)
    sed -i "s|^PROXMOX_TOKEN_VALUE=.*|PROXMOX_TOKEN_VALUE=$TOKEN_VALUE|" "$ENV_FILE"
    echo ""
    echo "✅ Token updated in $ENV_FILE"
else
    echo "❌ PROXMOX_TOKEN_VALUE not found in .env file"
    exit 1
fi

echo ""
echo "Verifying configuration..."
if grep -q "^PROXMOX_TOKEN_VALUE=$TOKEN_VALUE" "$ENV_FILE"; then
    echo "✅ Token successfully configured!"
    echo ""
    echo "Current configuration:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    grep "^PROXMOX_" "$ENV_FILE" | grep -v "TOKEN_VALUE" | sed 's/=.*/=***/'
    echo "PROXMOX_TOKEN_VALUE=***configured***"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "You can now test the connection:"
    echo "  ./verify-setup.sh"
    echo "  pnpm test:basic"
else
    echo "⚠️  Token may not have been updated correctly"
fi

