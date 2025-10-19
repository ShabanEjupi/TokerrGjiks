#!/bin/bash

# Interactive script to set up GitHub secrets via CLI
# This makes it easy to add all your API keys as secrets

echo "🔐 GitHub Secrets Setup Script"
echo "================================"
echo ""
echo "This script will help you add API keys as GitHub repository secrets."
echo "You can paste values when prompted, or skip optional ones by pressing Enter."
echo ""

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed."
    echo "Install it with: sudo apt install gh"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo "⚠️  You're not logged into GitHub CLI."
    echo "Please run: gh auth login"
    exit 1
fi

echo "✅ GitHub CLI is ready!"
echo ""

# Function to set a secret
set_secret() {
    local secret_name=$1
    local secret_description=$2
    local default_value=$3
    local is_required=$4
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📌 $secret_description"
    echo "Secret name: $secret_name"
    
    if [ -n "$default_value" ]; then
        echo "Current/Suggested value: $default_value"
    fi
    
    if [ "$is_required" == "yes" ]; then
        echo "⚠️  REQUIRED"
    else
        echo "ℹ️  Optional - Press Enter to skip"
    fi
    
    echo ""
    read -p "Enter value (or press Enter to ${is_required:+use suggested value}${is_required:-skip}): " value
    
    # Use default if provided and no input given
    if [ -z "$value" ] && [ -n "$default_value" ]; then
        value="$default_value"
    fi
    
    # Set the secret if value is provided
    if [ -n "$value" ]; then
        echo "$value" | gh secret set "$secret_name"
        if [ $? -eq 0 ]; then
            echo "✅ Set $secret_name"
        else
            echo "❌ Failed to set $secret_name"
        fi
    else
        echo "⏭️  Skipped $secret_name"
    fi
    echo ""
}

# AdMob Secrets (your students already provided these)
echo "📱 ADMOB API KEYS"
echo "Your students already provided these values."
echo "Press Enter to use them, or paste new values."
echo ""

set_secret "ADMOB_APP_ID_ANDROID" \
    "AdMob App ID for Android" \
    "ca-app-pub-8491001524308476~9753001043" \
    "yes"

set_secret "ADMOB_APP_ID_IOS" \
    "AdMob App ID for iOS" \
    "ca-app-pub-8491001524308476~5326670873" \
    "yes"

set_secret "ADMOB_BANNER_ANDROID" \
    "AdMob Banner Ad Unit ID for Android" \
    "ca-app-pub-8491001524308476/7116257088" \
    "yes"

set_secret "ADMOB_BANNER_IOS" \
    "AdMob Banner Ad Unit ID for iOS" \
    "ca-app-pub-8491001524308476/4681665438" \
    "yes"

set_secret "ADMOB_INTERSTITIAL_ANDROID" \
    "AdMob Interstitial Ad Unit ID for Android" \
    "ca-app-pub-8491001524308476/9581997693" \
    "yes"

set_secret "ADMOB_INTERSTITIAL_IOS" \
    "AdMob Interstitial Ad Unit ID for iOS" \
    "ca-app-pub-8491001524308476/5179718251" \
    "yes"

set_secret "ADMOB_REWARDED_ANDROID" \
    "AdMob Rewarded Ad Unit ID for Android (gives 2 points)" \
    "ca-app-pub-8491001524308476/8248347684" \
    "yes"

set_secret "ADMOB_REWARDED_IOS" \
    "AdMob Rewarded Ad Unit ID for iOS (gives 2 points)" \
    "ca-app-pub-8491001524308476/3041280706" \
    "yes"

echo ""
echo "💳 STRIPE PAYMENT KEYS (Optional)"
echo "Get these from: https://dashboard.stripe.com/apikeys"
echo ""

set_secret "STRIPE_PUBLISHABLE_KEY" \
    "Stripe Publishable Key (starts with pk_test_ or pk_live_)" \
    "" \
    "no"

set_secret "STRIPE_SECRET_KEY" \
    "Stripe Secret Key (starts with sk_test_ or sk_live_)" \
    "" \
    "no"

echo ""
echo "🐛 SENTRY ERROR TRACKING (Optional)"
echo "Get this from: https://sentry.io/settings/[org]/projects/[project]/keys/"
echo ""

set_secret "SENTRY_DSN" \
    "Sentry DSN for error tracking" \
    "" \
    "no"

echo ""
echo "🖥️  BACKEND SERVER URLs (Optional)"
echo "Set these when you have a deployed backend server"
echo ""

set_secret "SERVER_URL_PROD" \
    "Production Server URL" \
    "" \
    "no"

set_secret "WEBSOCKET_URL_PROD" \
    "Production WebSocket URL" \
    "" \
    "no"

echo ""
echo "📊 ANALYTICS & OTHER SERVICES (Optional)"
echo ""

set_secret "NEW_RELIC_LICENSE_KEY" \
    "New Relic License Key for APM" \
    "" \
    "no"

set_secret "DEVCYCLE_SDK_KEY" \
    "DevCycle SDK Key for feature flags" \
    "" \
    "no"

set_secret "BLOCKCHAIR_API_KEY" \
    "Blockchair API Key for blockchain data" \
    "" \
    "no"

set_secret "ICONS8_API_KEY" \
    "Icons8 API Key" \
    "" \
    "no"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ GitHub Secrets Setup Complete!"
echo ""
echo "Next steps:"
echo "1. View your secrets at: https://github.com/ShabanEjupi/TokerrGjiks/settings/secrets/actions"
echo "2. GitHub Actions should now build successfully!"
echo "3. Set up Netlify deployment with: netlify login && netlify link"
echo ""
echo "To verify, check the GitHub Actions: https://github.com/ShabanEjupi/TokerrGjiks/actions"
echo ""
