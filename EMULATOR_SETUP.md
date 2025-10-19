# Emulator Setup Guide

## ✅ Android Emulator (CONFIGURED)

The Android emulator has been successfully installed in this dev container!

### Starting the Emulator

```bash
export ANDROID_HOME=~/Android
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator

# Start emulator in background (headless mode for Codespaces)
emulator -avd test_device -no-window -no-audio -no-boot-anim &

# Wait for device to boot
adb wait-for-device

# Install and test APK
adb install tokerrgjik_mobile/build/app/outputs/flutter-apk/app-release.apk

# View logs
adb logcat | grep "flutter\|TokerrGjik"
```

### Available Device
- **Name**: test_device
- **Platform**: Android 34 (Android 14)
- **Type**: Pixel 5
- **ABI**: x86_64

## ❌ iOS Simulator (NOT FEASIBLE in Codespaces)

### Why OSX-KVM Won't Work Here

The OSX-KVM project (https://github.com/kholia/OSX-KVM) allows running macOS in a VM using QEMU/KVM on Linux. However, it has severe limitations in a cloud dev container:

1. **Resource Requirements**:
   - Minimum 16GB RAM (Codespaces has ~8GB)
   - 8+ CPU cores recommended
   - 60GB+ disk space for macOS + Xcode
   
2. **Virtualization Constraints**:
   - Requires nested virtualization (KVM inside container)
   - Codespaces doesn't support nested virtualization
   - Requires `/dev/kvm` access which is restricted

3. **Performance Issues**:
   - macOS would run extremely slow
   - iOS Simulator inside would be unusable
   - Network configuration is complex

4. **Legal Concerns**:
   - macOS EULA only permits running on Apple hardware
   - Commercial use restrictions apply

### Alternatives for iOS Testing

1. **Use Real Mac/MacBook**:
   ```bash
   # On your Mac
   cd tokerrgjik_mobile
   flutter build ios
   open ios/Runner.xcworkspace
   # Run from Xcode
   ```

2. **GitHub Actions** (Already configured!):
   - iOS builds run on macOS-14 runners
   - Download IPA from: https://github.com/ShabanEjupi/TokerrGjiks/actions
   - Install on physical iPhone/iPad for testing

3. **Cloud Mac Services**:
   - MacStadium (dedicated Mac hosting)
   - MacinCloud (rental Mac access)
   - AWS EC2 Mac instances

4. **TestFlight** (Recommended):
   - Upload IPA to App Store Connect
   - Distribute to testers via TestFlight
   - Best for real device testing

## Recommendation

**For Development**: Use Android emulator in Codespaces for fast iteration and testing.

**For iOS Testing**: Download IPA builds from GitHub Actions and test on real devices or use TestFlight.

**For Production**: Both platforms build successfully in CI/CD pipeline!
