#!/bin/bash
# Quick Setup - Run this after cloning the repository

echo "╔════════════════════════════════════════════════════════╗"
echo "║  TokerrGjiks - Quick Setup Guide                      ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

echo "📋 Setup Steps:"
echo ""
echo "1️⃣  Add GitHub Secrets (Required for CI/CD)"
echo "   Run: ./scripts/setup_github_secrets.sh"
echo "   This adds your Cryptolens keys to GitHub Actions"
echo ""

echo "2️⃣  Install Flutter Dependencies"
echo "   cd tokerrgjik_mobile"
echo "   flutter pub get"
echo ""

echo "3️⃣  Run the App"
echo ""
echo "   Option A - With License Protection:"
echo "   ./scripts/build_local.sh run"
echo ""
echo "   Option B - Without License (Dev Mode):"
echo "   cd tokerrgjik_mobile && flutter run"
echo ""

echo "4️⃣  Test English Translation"
echo "   - Open the app"
echo "   - Go to Settings"
echo "   - Select 'English' language"
echo "   - Navigate through the app"
echo ""

echo "5️⃣  Build Production APK"
echo "   ./scripts/build_local.sh apk"
echo ""

echo "═══════════════════════════════════════════════════════"
echo "📚 Documentation:"
echo "   - FIXES_COMPLETE.md - All changes summary"
echo "   - SECURE_KEYS_SETUP.md - Security guide"
echo "   - ENGLISH_AND_LICENSE.md - Feature documentation"
echo "═══════════════════════════════════════════════════════"
echo ""

echo "✅ Your app now has:"
echo "   ✓ English translation (100+ strings)"
echo "   ✓ Cryptolens license protection"
echo "   ✓ Secure key management"
echo "   ✓ Patent-protected algorithms"
echo "   ✓ Fixed compilation errors"
echo ""

echo "🚀 Ready to deploy!"
