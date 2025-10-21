#!/bin/bash
# Local Development Build Script with Cryptolens Keys
# This script reads keys from .env and builds the app

set -e

cd "$(dirname "$0")/.."

if [ ! -f ".env" ]; then
    echo "❌ Error: .env file not found"
    echo ""
    echo "For development without Cryptolens (no license check):"
    echo "  cd tokerrgjik_mobile"
    echo "  flutter run"
    echo ""
    echo "The app will work but license features will be disabled."
    exit 1
fi

# Extract values from .env
PRODUCT_ID=$(grep "^PRODUCT_ID=" .env | cut -d'=' -f2 | tr -d '"')
ACCESS_TOKEN=$(grep "^ACCESS_TOKEN=" .env | cut -d'=' -f2 | tr -d '"')
RSA_PUBLIC_KEY=$(grep "^RSA_PUBLIC_KEY=" .env | cut -d'=' -f2 | tr -d '"')

echo "🔐 Building with Cryptolens license protection..."
echo ""

cd tokerrgjik_mobile

# Determine what to build based on first argument
BUILD_TYPE="${1:-run}"

case "$BUILD_TYPE" in
    run)
        echo "🏃 Running app in development mode..."
        flutter run \
            --dart-define=CRYPTOLENS_PRODUCT_ID="$PRODUCT_ID" \
            --dart-define=CRYPTOLENS_ACCESS_TOKEN="$ACCESS_TOKEN" \
            --dart-define=CRYPTOLENS_RSA_PUBLIC_KEY="$RSA_PUBLIC_KEY"
        ;;
    
    apk)
        echo "📦 Building Android APK..."
        flutter build apk --release \
            --dart-define=CRYPTOLENS_PRODUCT_ID="$PRODUCT_ID" \
            --dart-define=CRYPTOLENS_ACCESS_TOKEN="$ACCESS_TOKEN" \
            --dart-define=CRYPTOLENS_RSA_PUBLIC_KEY="$RSA_PUBLIC_KEY"
        echo ""
        echo "✅ APK built: build/app/outputs/flutter-apk/app-release.apk"
        ;;
    
    ios)
        echo "🍎 Building iOS..."
        flutter build ios --release --no-codesign \
            --dart-define=CRYPTOLENS_PRODUCT_ID="$PRODUCT_ID" \
            --dart-define=CRYPTOLENS_ACCESS_TOKEN="$ACCESS_TOKEN" \
            --dart-define=CRYPTOLENS_RSA_PUBLIC_KEY="$RSA_PUBLIC_KEY"
        echo ""
        echo "✅ iOS built: build/ios/iphoneos/Runner.app"
        ;;
    
    web)
        echo "🌐 Building Web..."
        flutter build web --release \
            --dart-define=CRYPTOLENS_PRODUCT_ID="$PRODUCT_ID" \
            --dart-define=CRYPTOLENS_ACCESS_TOKEN="$ACCESS_TOKEN" \
            --dart-define=CRYPTOLENS_RSA_PUBLIC_KEY="$RSA_PUBLIC_KEY"
        echo ""
        echo "✅ Web built: build/web/"
        ;;
    
    *)
        echo "❌ Unknown build type: $BUILD_TYPE"
        echo ""
        echo "Usage: $0 [run|apk|ios|web]"
        echo ""
        echo "Examples:"
        echo "  $0 run    # Run in development mode"
        echo "  $0 apk    # Build Android APK"
        echo "  $0 ios    # Build iOS app"
        echo "  $0 web    # Build web version"
        exit 1
        ;;
esac
