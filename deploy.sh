#!/bin/bash

echo "═══════════════════════════════════════════════════════════════"
echo "🚀 DEPLOYING TOKERRGJIK TO NETLIFY"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Build the Flutter web app
echo "📦 Building Flutter web app..."
cd tokerrgjik_mobile
flutter build web --release --web-renderer canvaskit

echo ""
echo "✅ Build complete!"
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "🔐 NETLIFY DEPLOYMENT"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "Step 1: Login to Netlify"
echo "Run: netlify login"
echo ""
echo "Step 2: Deploy (choose 'Create & configure a new site')"
echo "Run: netlify deploy --dir=build/web --prod"
echo ""
echo "OR use drag-and-drop:"
echo "1. Go to: https://app.netlify.com/drop"
echo "2. Drag the folder: tokerrgjik_mobile/build/web"
echo "3. Get instant URL!"
echo ""
echo "Build is ready at: tokerrgjik_mobile/build/web"
echo "═══════════════════════════════════════════════════════════════"
