#!/bin/bash
# Tokerrgjik Icon Generator
# This script generates all required icons from a source image
# Usage: ./generate_icons.sh /path/to/source_icon.png

set -e

SOURCE_IMAGE="$1"

if [ -z "$SOURCE_IMAGE" ]; then
    echo "Usage: ./generate_icons.sh /path/to/source_icon.png"
    echo "Example: ./generate_icons.sh tokerrgjik_mobile/web/tokerrgjik_icon.png"
    exit 1
fi

if [ ! -f "$SOURCE_IMAGE" ]; then
    echo "Error: Source image not found: $SOURCE_IMAGE"
    exit 1
fi

echo "🎨 Generating icons from: $SOURCE_IMAGE"
echo ""

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "⚠️  ImageMagick not installed. Installing..."
    sudo apt-get update && sudo apt-get install -y imagemagick
fi

BASE_DIR="tokerrgjik_mobile"

# Web Icons (Favicons)
echo "🌐 Generating web icons..."
mkdir -p "$BASE_DIR/web/icons"

convert "$SOURCE_IMAGE" -resize 16x16 "$BASE_DIR/web/icons/favicon-16x16.png"
convert "$SOURCE_IMAGE" -resize 32x32 "$BASE_DIR/web/icons/favicon-32x32.png"
convert "$SOURCE_IMAGE" -resize 192x192 "$BASE_DIR/web/icons/Icon-192.png"
convert "$SOURCE_IMAGE" -resize 512x512 "$BASE_DIR/web/icons/Icon-512.png"
convert "$SOURCE_IMAGE" -resize 192x192 "$BASE_DIR/web/icons/Icon-maskable-192.png"
convert "$SOURCE_IMAGE" -resize 512x512 "$BASE_DIR/web/icons/Icon-maskable-512.png"

# Create ICO file for Windows
convert "$SOURCE_IMAGE" -resize 16x16 -resize 32x32 -resize 48x48 "$BASE_DIR/web/favicon.ico" 2>/dev/null || echo "  Skipping .ico generation"

echo "  ✓ favicon-16x16.png"
echo "  ✓ favicon-32x32.png"
echo "  ✓ Icon-192.png"
echo "  ✓ Icon-512.png"
echo "  ✓ Icon-maskable-192.png"
echo "  ✓ Icon-maskable-512.png"

# Android Icons
echo ""
echo "📱 Generating Android icons..."
ANDROID_RES="$BASE_DIR/android/app/src/main/res"
mkdir -p "$ANDROID_RES/mipmap-mdpi"
mkdir -p "$ANDROID_RES/mipmap-hdpi"
mkdir -p "$ANDROID_RES/mipmap-xhdpi"
mkdir -p "$ANDROID_RES/mipmap-xxhdpi"
mkdir -p "$ANDROID_RES/mipmap-xxxhdpi"

convert "$SOURCE_IMAGE" -resize 48x48 "$ANDROID_RES/mipmap-mdpi/ic_launcher.png"
convert "$SOURCE_IMAGE" -resize 72x72 "$ANDROID_RES/mipmap-hdpi/ic_launcher.png"
convert "$SOURCE_IMAGE" -resize 96x96 "$ANDROID_RES/mipmap-xhdpi/ic_launcher.png"
convert "$SOURCE_IMAGE" -resize 144x144 "$ANDROID_RES/mipmap-xxhdpi/ic_launcher.png"
convert "$SOURCE_IMAGE" -resize 192x192 "$ANDROID_RES/mipmap-xxxhdpi/ic_launcher.png"

echo "  ✓ mdpi (48x48)"
echo "  ✓ hdpi (72x72)"
echo "  ✓ xhdpi (96x96)"
echo "  ✓ xxhdpi (144x144)"
echo "  ✓ xxxhdpi (192x192)"

# iOS Icons
echo ""
echo "🍎 Generating iOS icons..."
IOS_ASSETS="$BASE_DIR/ios/Runner/Assets.xcassets/AppIcon.appiconset"
mkdir -p "$IOS_ASSETS"

# iOS requires specific sizes
convert "$SOURCE_IMAGE" -resize 20x20 "$IOS_ASSETS/Icon-App-20x20@1x.png"
convert "$SOURCE_IMAGE" -resize 40x40 "$IOS_ASSETS/Icon-App-20x20@2x.png"
convert "$SOURCE_IMAGE" -resize 60x60 "$IOS_ASSETS/Icon-App-20x20@3x.png"
convert "$SOURCE_IMAGE" -resize 29x29 "$IOS_ASSETS/Icon-App-29x29@1x.png"
convert "$SOURCE_IMAGE" -resize 58x58 "$IOS_ASSETS/Icon-App-29x29@2x.png"
convert "$SOURCE_IMAGE" -resize 87x87 "$IOS_ASSETS/Icon-App-29x29@3x.png"
convert "$SOURCE_IMAGE" -resize 40x40 "$IOS_ASSETS/Icon-App-40x40@1x.png"
convert "$SOURCE_IMAGE" -resize 80x80 "$IOS_ASSETS/Icon-App-40x40@2x.png"
convert "$SOURCE_IMAGE" -resize 120x120 "$IOS_ASSETS/Icon-App-40x40@3x.png"
convert "$SOURCE_IMAGE" -resize 120x120 "$IOS_ASSETS/Icon-App-60x60@2x.png"
convert "$SOURCE_IMAGE" -resize 180x180 "$IOS_ASSETS/Icon-App-60x60@3x.png"
convert "$SOURCE_IMAGE" -resize 76x76 "$IOS_ASSETS/Icon-App-76x76@1x.png"
convert "$SOURCE_IMAGE" -resize 152x152 "$IOS_ASSETS/Icon-App-76x76@2x.png"
convert "$SOURCE_IMAGE" -resize 167x167 "$IOS_ASSETS/Icon-App-83.5x83.5@2x.png"
convert "$SOURCE_IMAGE" -resize 1024x1024 "$IOS_ASSETS/Icon-App-1024x1024@1x.png"

echo "  ✓ All iOS icon sizes generated"

# Create Contents.json for iOS
cat > "$IOS_ASSETS/Contents.json" << 'EOF'
{
  "images": [
    {"size": "20x20", "idiom": "iphone", "filename": "Icon-App-20x20@2x.png", "scale": "2x"},
    {"size": "20x20", "idiom": "iphone", "filename": "Icon-App-20x20@3x.png", "scale": "3x"},
    {"size": "29x29", "idiom": "iphone", "filename": "Icon-App-29x29@1x.png", "scale": "1x"},
    {"size": "29x29", "idiom": "iphone", "filename": "Icon-App-29x29@2x.png", "scale": "2x"},
    {"size": "29x29", "idiom": "iphone", "filename": "Icon-App-29x29@3x.png", "scale": "3x"},
    {"size": "40x40", "idiom": "iphone", "filename": "Icon-App-40x40@2x.png", "scale": "2x"},
    {"size": "40x40", "idiom": "iphone", "filename": "Icon-App-40x40@3x.png", "scale": "3x"},
    {"size": "60x60", "idiom": "iphone", "filename": "Icon-App-60x60@2x.png", "scale": "2x"},
    {"size": "60x60", "idiom": "iphone", "filename": "Icon-App-60x60@3x.png", "scale": "3x"},
    {"size": "20x20", "idiom": "ipad", "filename": "Icon-App-20x20@1x.png", "scale": "1x"},
    {"size": "20x20", "idiom": "ipad", "filename": "Icon-App-20x20@2x.png", "scale": "2x"},
    {"size": "29x29", "idiom": "ipad", "filename": "Icon-App-29x29@1x.png", "scale": "1x"},
    {"size": "29x29", "idiom": "ipad", "filename": "Icon-App-29x29@2x.png", "scale": "2x"},
    {"size": "40x40", "idiom": "ipad", "filename": "Icon-App-40x40@1x.png", "scale": "1x"},
    {"size": "40x40", "idiom": "ipad", "filename": "Icon-App-40x40@2x.png", "scale": "2x"},
    {"size": "76x76", "idiom": "ipad", "filename": "Icon-App-76x76@1x.png", "scale": "1x"},
    {"size": "76x76", "idiom": "ipad", "filename": "Icon-App-76x76@2x.png", "scale": "2x"},
    {"size": "83.5x83.5", "idiom": "ipad", "filename": "Icon-App-83.5x83.5@2x.png", "scale": "2x"},
    {"size": "1024x1024", "idiom": "ios-marketing", "filename": "Icon-App-1024x1024@1x.png", "scale": "1x"}
  ],
  "info": {"version": 1, "author": "xcode"}
}
EOF

echo "  ✓ Contents.json created"

# Summary
echo ""
echo "✅ Icon generation complete!"
echo ""
echo "📊 Summary:"
echo "  - Web icons: 6 files generated"
echo "  - Android icons: 5 density levels"
echo "  - iOS icons: 15 sizes + Contents.json"
echo ""
echo "🔍 Next steps:"
echo "  1. Check the generated icons"
echo "  2. Rebuild your Flutter app: flutter clean && flutter build"
echo "  3. The icons will be included in your next build"
echo ""
echo "💡 Tip: For Canva users, export as PNG with transparent background"
echo "   Recommended size: 1024x1024px or larger"

