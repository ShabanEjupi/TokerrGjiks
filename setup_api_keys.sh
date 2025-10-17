#!/bin/bash

# API Keys Setup Helper Script
# This script guides you through obtaining and configuring API keys for the TokerrGjiks app

echo "=========================================="
echo "TokerrGjiks - API Keys Setup Helper"
echo "=========================================="
echo ""

API_KEYS_FILE="tokerrgjik_mobile/lib/config/api_keys.dart"
API_KEYS_TEMPLATE="tokerrgjik_mobile/lib/config/api_keys.dart.template"

# Check if we're in the right directory
if [ ! -f "$API_KEYS_TEMPLATE" ]; then
    echo "Error: Template file not found!"
    echo "Please run this script from the project root directory."
    exit 1
fi

# Create api_keys.dart from template if it doesn't exist
if [ ! -f "$API_KEYS_FILE" ]; then
    echo "Creating api_keys.dart from template..."
    cp "$API_KEYS_TEMPLATE" "$API_KEYS_FILE"
    echo "✓ api_keys.dart created"
    echo ""
fi

echo "This script will help you set up the API keys needed for the app."
echo ""

# Function to open URL in default browser
open_url() {
    if command -v xdg-open > /dev/null; then
        xdg-open "$1" &
    elif command -v open > /dev/null; then
        open "$1" &
    elif command -v start > /dev/null; then
        start "$1" &
    else
        echo "Please open this URL manually: $1"
    fi
}

# AdMob Setup
echo "1. Google AdMob (for ads)"
echo "   - Visit: https://admob.google.com/"
echo "   - Create an account or sign in"
echo "   - Create a new app"
echo "   - Create ad units: Banner, Interstitial, and Rewarded"
echo "   - Get your Ad Unit IDs"
echo ""
read -p "Would you like to open AdMob now? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    open_url "https://admob.google.com/"
fi

read -p "Do you have your Android Banner Ad Unit ID? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "Enter Android Banner Ad Unit ID: " android_banner
    sed -i "s|admobBannerAndroid = 'ca-app-pub-[^']*'|admobBannerAndroid = '$android_banner'|g" "$API_KEYS_FILE"
    echo "✓ Android Banner Ad Unit ID saved"
fi

echo ""

# Sentry Setup
echo "2. Sentry (for error tracking)"
echo "   - Visit: https://sentry.io/"
echo "   - Create an account or sign in"
echo "   - Create a new project (Flutter)"
echo "   - Copy your DSN"
echo ""
read -p "Would you like to open Sentry now? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    open_url "https://sentry.io/"
fi

read -p "Do you have your Sentry DSN? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "Enter Sentry DSN: " sentry_dsn
    sed -i "s|sentryDsn = ''|sentryDsn = '$sentry_dsn'|g" "$API_KEYS_FILE"
    sed -i "s|enableSentry = false|enableSentry = true|g" "$API_KEYS_FILE"
    echo "✓ Sentry DSN saved"
fi

echo ""

# Stripe Setup
echo "3. Stripe (for payments - optional)"
echo "   - Visit: https://stripe.com/"
echo "   - Create an account or sign in"
echo "   - Get your publishable key from the dashboard"
echo "   - Use test keys for development"
echo ""
read -p "Would you like to open Stripe now? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    open_url "https://stripe.com/"
fi

read -p "Do you have your Stripe publishable key? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "Enter Stripe publishable key: " stripe_key
    sed -i "s|stripePublishableKey = ''|stripePublishableKey = '$stripe_key'|g" "$API_KEYS_FILE"
    sed -i "s|enablePayments = false|enablePayments = true|g" "$API_KEYS_FILE"
    echo "✓ Stripe publishable key saved"
fi

echo ""
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "API keys have been configured in: $API_KEYS_FILE"
echo ""
echo "Note: The API keys file is in .gitignore and will not be committed."
echo "      Keep your API keys secure and never share them publicly."
echo ""
echo "For production deployment, you'll need to:"
echo "  - Replace test AdMob IDs with your real production IDs"
echo "  - Use production Stripe keys instead of test keys"
echo "  - Configure your backend server URL if using multiplayer features"
echo ""
echo "You can now run: cd tokerrgjik_mobile && flutter run"
echo ""
