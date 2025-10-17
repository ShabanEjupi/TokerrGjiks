#!/bin/bash

echo "═══════════════════════════════════════════════════════════════"
echo "🚀 DEPLOYING TOKERRGJIK TO NETLIFY"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Build the Flutter web app
echo "📦 Building Flutter web app..."
cd tokerrgjik_mobile
flutter build web --release

echo ""
echo "✅ Build complete!"
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "🔐 LOGIN REQUIRED"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "Opening browser for Netlify login..."
echo "After logging in, come back to this terminal."
echo ""

cd ..
netlify deploy --dir=tokerrgjik_mobile/build/web --prod

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "✅ DEPLOYMENT COMPLETE!"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "Your game is now live! 🎮"
echo ""
