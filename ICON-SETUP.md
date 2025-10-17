# 🎨 Icon Setup Guide for Tokerrgjik

## Quick Start

1. **Create your icon in Canva** (or any design tool)
   - Size: **1024x1024 pixels** (minimum 512x512)
   - Format: **PNG** with **transparent background**
   - Design: Simple, recognizable icon representing the game

2. **Export and upload**
   - Save as `tokerrgjik_icon.png`
   - Upload to `/workspaces/TokerrGjiks/tokerrgjik_mobile/web/`

3. **Run the generator script**
   ```bash
   cd /workspaces/TokerrGjiks
   ./generate_icons.sh tokerrgjik_mobile/web/tokerrgjik_icon.png
   ```

4. **Rebuild the app**
   ```bash
   cd tokerrgjik_mobile
   flutter clean
   flutter build web
   ```

## What This Does

The script automatically generates icons for:

### Web (6 files)
- `favicon.ico` - Browser tab icon
- `favicon-16x16.png` - Small browser icon
- `favicon-32x32.png` - Standard browser icon
- `Icon-192.png` - PWA icon
- `Icon-512.png` - Large PWA icon
- `Icon-maskable-192.png` - Adaptive icon (Android PWA)
- `Icon-maskable-512.png` - Large adaptive icon

### Android (5 densities)
- `mipmap-mdpi/ic_launcher.png` (48x48)
- `mipmap-hdpi/ic_launcher.png` (72x72)
- `mipmap-xhdpi/ic_launcher.png` (96x96)
- `mipmap-xxhdpi/ic_launcher.png` (144x144)
- `mipmap-xxxhdpi/ic_launcher.png` (192x192)

### iOS (15 sizes)
- All required App Icon sizes (20pt to 1024pt)
- Includes 1x, 2x, and 3x scales
- `Contents.json` metadata file

## Design Tips

### Good Icon Design
✅ Simple and recognizable at small sizes
✅ High contrast (looks good dark or light)
✅ Centered design with padding
✅ Represents the game (board, pieces, traditional motif)
✅ Transparent or solid background

### Avoid
❌ Too much detail (gets blurry when small)
❌ Thin lines (disappear at small sizes)
❌ Text (unreadable in small icons)
❌ Multiple colors (keep it simple)

## Canva Design Guide

1. **Create custom size**: 1024 x 1024 px
2. **Add elements**:
   - Circle or square for the board
   - Simple pieces (circles/dots)
   - Albanian flag colors (optional): Red (#E41E20), Black
3. **Export**:
   - File → Download
   - Type: PNG
   - Check "Transparent background"

## Example Icon Ideas

### Option 1: Traditional Board
- Beige/wood colored circle
- Three concentric squares (like the game board)
- Black and white pieces on corners

### Option 2: Abstract Pieces
- Two circles (black & cream)
- Overlapping or side-by-side
- On colored background

### Option 3: Albanian Theme
- Red circle background
- Black eagle silhouette (simplified)
- White game pieces

## Troubleshooting

### Script fails with "convert: command not found"
The script will auto-install ImageMagick. If it fails:
```bash
sudo apt-get update
sudo apt-get install imagemagick
```

### Icons don't update after rebuild
1. Clear browser cache (Ctrl+Shift+R)
2. For Android: Uninstall and reinstall app
3. For iOS: Clean build folder in Xcode

### Icon looks pixelated
- Use a larger source image (1024x1024 or bigger)
- Export from Canva at highest quality
- Ensure the design is vector-based if possible

## Manual Upload (Alternative)

If you prefer to manually upload icons:

1. **Web**: Place in `tokerrgjik_mobile/web/icons/`
2. **Android**: Place in `tokerrgjik_mobile/android/app/src/main/res/mipmap-*/`
3. **iOS**: Place in `tokerrgjik_mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset/`

Use this naming convention:
- Web: `Icon-192.png`, `Icon-512.png`
- Android: `ic_launcher.png` (in appropriate density folder)
- iOS: See `Contents.json` for exact filenames

## After Icon Generation

The icons will be automatically included in your next build:

```bash
# Web
flutter build web --release

# Android
flutter build apk --release
flutter build appbundle --release

# iOS (requires macOS)
flutter build ios --release
```

## Testing Icons

### Web
1. Build: `flutter build web`
2. Check `build/web/icons/` folder
3. Open in browser and check favicon

### Android
1. Build: `flutter build apk`
2. Install on device: `flutter install`
3. Check app icon in launcher

### iOS
1. Open Xcode project
2. Check Assets.xcassets → AppIcon
3. Build and run on simulator

## Need Help?

- Check the generated files in their respective folders
- Make sure your source image is at least 512x512 pixels
- Use PNG format with transparent background
- Test the icon at different sizes before finalizing

---

**Ready to create your icon?**
1. Design in Canva
2. Upload as `tokerrgjik_mobile/web/tokerrgjik_icon.png`
3. Run `./generate_icons.sh tokerrgjik_mobile/web/tokerrgjik_icon.png`
4. Done! 🎉
