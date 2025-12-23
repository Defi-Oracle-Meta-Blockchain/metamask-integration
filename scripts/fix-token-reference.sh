#!/bin/bash
# Fix token reference - checks if token needs to be updated
# This script helps identify if the token value is still a placeholder

ENV_FILE="$HOME/.env"

if [ ! -f "$ENV_FILE" ]; then
    echo "❌ .env file not found: $ENV_FILE"
    exit 1
fi

# Check current token value
TOKEN_VALUE=$(grep "^PROXMOX_TOKEN_VALUE=" "$ENV_FILE" | cut -d'=' -f2- | tr -d '"' | tr -d "'")

PLACEHOLDERS=(
    "your-token-secret-here"
    "your-token-secret"
    "your-token-secret-value"
    ""
)

IS_PLACEHOLDER=false
for placeholder in "${PLACEHOLDERS[@]}"; do
    if [ "$TOKEN_VALUE" = "$placeholder" ]; then
        IS_PLACEHOLDER=true
        break
    fi
done

if [ "$IS_PLACEHOLDER" = true ]; then
    echo "⚠️  Token value is still a placeholder"
    echo ""
    echo "Current value: $TOKEN_VALUE"
    echo ""
    echo "To fix:"
    echo "  1. Run: ./scripts/update-token.sh"
    echo "  2. Or manually edit: $ENV_FILE"
    echo "     Change PROXMOX_TOKEN_VALUE to the actual token secret"
    echo ""
    echo "The token was created with ID: bff429d3-f408-4139-807a-7bf163525275"
    echo "You need the SECRET value (shown only once when token was created)"
    exit 1
else
    TOKEN_LEN=${#TOKEN_VALUE}
    if [ $TOKEN_LEN -lt 20 ]; then
        echo "⚠️  Token value seems too short ($TOKEN_LEN chars)"
        echo "   Expected: 30+ characters (UUID format)"
    else
        echo "✅ Token value appears configured ($TOKEN_LEN characters)"
        echo "   Testing connection..."
        
        # Test connection
        source scripts/load-env.sh
        load_env_file
        
        API_RESPONSE=$(curl -k -s -w "\n%{http_code}" -m 10 \
            -H "Authorization: PVEAPIToken=${PROXMOX_USER}!${PROXMOX_TOKEN_NAME}=${PROXMOX_TOKEN_VALUE}" \
            "https://${PROXMOX_HOST}:${PROXMOX_PORT:-8006}/api2/json/version" 2>&1)
        
        HTTP_CODE=$(echo "$API_RESPONSE" | tail -1)
        
        if [ "$HTTP_CODE" = "200" ]; then
            echo "✅ API connection successful!"
            exit 0
        else
            echo "❌ API connection failed (HTTP $HTTP_CODE)"
            echo "   Token may be incorrect or expired"
            exit 1
        fi
    fi
fi

