# Tokerrgjik - Quick Start Guide

## ✅ ALL ISSUES FIXED!

### What was fixed:
1. **Android SDK Updated** - Changed from SDK 35 to SDK 36 (required by latest plugins)
2. **Google Ads Crash Fixed** - Added required Application ID to AndroidManifest
3. **No Emulator Needed** - Configured to run on Windows directly

---

## 🚀 HOW TO RUN THE GAME

### **Option 1: Windows (RECOMMENDED - No emulator needed!)**

```powershell
cd tokerrgjik_mobile
flutter run -d windows
```

**This is the EASIEST and FASTEST way!**
- No emulator installation required
- Runs natively on Windows
- All features work (except ads, which are disabled on desktop)

---

## 📋 What Changed in the Code

### 1. `android/app/build.gradle.kts`
- Changed `compileSdk = 35` → `compileSdk = 36`
- Changed `targetSdk = 35` → `targetSdk = 36`

### 2. `android/app/src/main/AndroidManifest.xml`
- Added Google Mobile Ads Application ID (test ID):
```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-3940256099942544~3347511713"/>
```

### 3. Ad Service Already Configured
The `lib/services/ad_service.dart` already has proper error handling for desktop platforms.

---

## 🎮 Game Features

- ✅ Play against AI (4 difficulty levels)
- ✅ Local multiplayer
- ✅ Undo/Redo moves
- ✅ Custom themes and colors
- ✅ Sound effects and music
- ✅ Coins and shop system
- ✅ Leaderboard
- ⚠️ Ads (only work on Android/iOS, disabled on Windows)

---

## 🔧 Quick Setup Script

Run this script to clean and prepare the project:

```powershell
.\QUICK_FIX.ps1
```

Then run the game:
```powershell
cd tokerrgjik_mobile
flutter run -d windows
```

---

## 📱 If You Want to Try Android Later

If you get access to an emulator or physical device:

1. The AndroidManifest now has the required Ad ID
2. SDK version is updated to 36
3. Just run: `flutter run` (it will detect the Android device automatically)

---

## ⚠️ Important Notes

- **Ads will only work on real Android/iOS devices** (not on Windows/emulators)
- The test Ad ID is included for development
- Before publishing, replace the test Ad ID with your real AdMob App ID

---

## 🆘 Troubleshooting

### If you get "No devices found":
```powershell
flutter doctor
```
Make sure Windows desktop support is enabled.

### If you get build errors:
```powershell
cd tokerrgjik_mobile
flutter clean
flutter pub get
flutter run -d windows
```

---

## 🎉 You're All Set!

The game is ready to run on Windows. No emulator needed!
