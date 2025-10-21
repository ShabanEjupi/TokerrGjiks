#!/bin/bash
# GitHub Secrets Setup Script for Cryptolens Keys
# This script helps you add the required secrets to your GitHub repository

set -e

echo "=============================================="
echo "  Cryptolens GitHub Secrets Setup"
echo "=============================================="
echo ""

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "❌ Error: .env file not found in the current directory"
    echo "   Please run this script from the repository root"
    exit 1
fi

# Read values from .env file
echo "📖 Reading Cryptolens keys from .env file..."
echo ""

# Extract values
PRODUCT_ID=$(grep "^PRODUCT_ID=" .env | cut -d'=' -f2 | tr -d '"')
ACCESS_TOKEN=$(grep "^ACCESS_TOKEN=" .env | cut -d'=' -f2 | tr -d '"')
RSA_PUBLIC_KEY=$(grep "^RSA_PUBLIC_KEY=" .env | cut -d'=' -f2 | tr -d '"')

if [ -z "$PRODUCT_ID" ] || [ -z "$ACCESS_TOKEN" ] || [ -z "$RSA_PUBLIC_KEY" ]; then
    echo "❌ Error: Could not find all required keys in .env file"
    echo "   Make sure .env contains: PRODUCT_ID, ACCESS_TOKEN, RSA_PUBLIC_KEY"
    exit 1
fi

echo "✅ Found all required keys:"
echo "   - PRODUCT_ID: $PRODUCT_ID"
echo "   - ACCESS_TOKEN: ${ACCESS_TOKEN:0:20}..."
echo "   - RSA_PUBLIC_KEY: ${RSA_PUBLIC_KEY:0:30}..."
echo ""

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ Error: GitHub CLI (gh) is not installed"
    echo ""
    echo "Please install it first:"
    echo "  - macOS: brew install gh"
    echo "  - Linux: https://github.com/cli/cli/blob/trunk/docs/install_linux.md"
    echo "  - Windows: https://github.com/cli/cli#windows"
    echo ""
    echo "Then run: gh auth login"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo "❌ Error: Not authenticated with GitHub"
    echo ""
    echo "Please run: gh auth login"
    exit 1
fi

echo "=============================================="
echo "  Adding secrets to GitHub repository"
echo "=============================================="
echo ""

# Add secrets using gh CLI
echo "🔐 Adding CRYPTOLENS_PRODUCT_ID..."
echo "$PRODUCT_ID" | gh secret set CRYPTOLENS_PRODUCT_ID

echo "🔐 Adding CRYPTOLENS_ACCESS_TOKEN..."
echo "$ACCESS_TOKEN" | gh secret set CRYPTOLENS_ACCESS_TOKEN

echo "🔐 Adding CRYPTOLENS_RSA_PUBLIC_KEY..."
echo "$RSA_PUBLIC_KEY" | gh secret set CRYPTOLENS_RSA_PUBLIC_KEY

echo ""
echo "✅ SUCCESS! All secrets have been added to GitHub."
echo ""
echo "=============================================="
echo "  Next Steps"
echo "=============================================="
echo ""
echo "1. ✅ GitHub Secrets are configured"
echo "2. ⚠️  DELETE the .env file (it's no longer needed):"
echo "     rm .env"
echo ""
echo "3. 🚀 Your GitHub Actions workflows will now use these secrets"
echo ""
echo "4. 🔒 For local development, use --dart-define:"
echo ""
echo "   flutter run \\"
echo "     --dart-define=CRYPTOLENS_PRODUCT_ID=\"$PRODUCT_ID\" \\"
echo "     --dart-define=CRYPTOLENS_ACCESS_TOKEN=\"$ACCESS_TOKEN\" \\"
echo "     --dart-define=CRYPTOLENS_RSA_PUBLIC_KEY=\"$RSA_PUBLIC_KEY\""
echo ""
echo "   Or save this in a local script (add to .gitignore!)"
echo ""
echo "=============================================="
echo "  Security Checklist"
echo "=============================================="
echo ""
echo "✅ Secrets are encrypted in GitHub"
echo "✅ Secrets won't appear in workflow logs"
echo "✅ .env file can be safely deleted"
echo "⚠️  Make sure .env is in .gitignore (already done)"
echo "⚠️  Never commit API keys to git"
echo ""
echo "🎉 Setup complete!"
