#!/bin/bash

# App Publishing Helper Script
# This script helps you publish the app to Google Play Store and Apple App Store

echo "=========================================="
echo "TokerrGjiks - App Publishing Helper"
echo "=========================================="
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "Error: Flutter is not installed!"
    echo "Please install Flutter first: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "This script will guide you through publishing your app."
echo ""
echo "Choose platform:"
echo "1) Google Play Store (Android)"
echo "2) Apple App Store (iOS)"
echo "3) Both"
echo ""
read -p "Enter your choice (1-3): " platform_choice

# Function to open URL
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

publish_android() {
    echo ""
    echo "=========================================="
    echo "Publishing to Google Play Store"
    echo "=========================================="
    echo ""
    
    echo "Prerequisites:"
    echo "  1. Google Play Developer account ($25 one-time fee)"
    echo "  2. Signed app bundle (AAB file)"
    echo "  3. App signing key (keystore)"
    echo ""
    
    read -p "Do you have a Google Play Developer account? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Creating account..."
        open_url "https://play.google.com/console/signup"
        echo ""
        echo "Please complete the signup process and come back."
        read -p "Press Enter when you have your account ready..."
    fi
    
    echo ""
    echo "Step 1: Create/Check signing keystore"
    KEYSTORE_PATH="$HOME/tokerrgjik-release-key.jks"
    
    if [ ! -f "$KEYSTORE_PATH" ]; then
        echo "Creating new signing keystore..."
        read -p "Enter keystore password: " -s keystore_pass
        echo ""
        read -p "Enter key alias (e.g., tokerrgjik): " key_alias
        read -p "Enter your name: " dev_name
        read -p "Enter organization: " dev_org
        
        keytool -genkey -v -keystore "$KEYSTORE_PATH" \
            -alias "$key_alias" \
            -keyalg RSA -keysize 2048 -validity 10000 \
            -storepass "$keystore_pass" \
            -dname "CN=$dev_name, OU=$dev_org"
        
        echo "✓ Keystore created at: $KEYSTORE_PATH"
        echo ""
        echo "IMPORTANT: Keep this keystore safe! You'll need it for all future updates."
        echo "Back it up to a secure location."
    else
        echo "✓ Keystore found at: $KEYSTORE_PATH"
    fi
    
    echo ""
    echo "Step 2: Configure key.properties"
    KEY_PROPS="tokerrgjik_mobile/android/key.properties"
    
    if [ ! -f "$KEY_PROPS" ]; then
        read -p "Enter keystore password: " -s keystore_pass
        echo ""
        read -p "Enter key alias: " key_alias
        read -p "Enter key password: " -s key_pass
        echo ""
        
        cat > "$KEY_PROPS" << EOF
storePassword=$keystore_pass
keyPassword=$key_pass
keyAlias=$key_alias
storeFile=$KEYSTORE_PATH
EOF
        echo "✓ key.properties created"
    fi
    
    echo ""
    echo "Step 3: Building release AAB..."
    cd tokerrgjik_mobile
    flutter pub get
    flutter build appbundle --release
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "✓ App bundle built successfully!"
        echo "Location: tokerrgjik_mobile/build/app/outputs/bundle/release/app-release.aab"
        echo ""
        
        echo "Step 4: Upload to Play Console"
        open_url "https://play.google.com/console"
        
        echo ""
        echo "In the Play Console:"
        echo "  1. Create a new app"
        echo "  2. Fill in app details (title, description, screenshots)"
        echo "  3. Go to 'Release' > 'Production'"
        echo "  4. Upload the AAB file: build/app/outputs/bundle/release/app-release.aab"
        echo "  5. Complete content rating questionnaire"
        echo "  6. Set pricing (free/paid)"
        echo "  7. Submit for review"
        echo ""
        echo "Review typically takes 1-3 days."
    else
        echo "Error: Build failed!"
        exit 1
    fi
    
    cd ..
}

publish_ios() {
    echo ""
    echo "=========================================="
    echo "Publishing to Apple App Store"
    echo "=========================================="
    echo ""
    
    echo "Prerequisites:"
    echo "  1. Apple Developer account ($99/year)"
    echo "  2. Mac computer (required for iOS development)"
    echo "  3. Xcode installed"
    echo ""
    
    # Check if we're on macOS
    if [[ "$OSTYPE" != "darwin"* ]]; then
        echo "Error: iOS publishing requires a Mac computer!"
        echo ""
        echo "Options:"
        echo "  1. Use GitHub Actions with macOS runner (already configured in this repo)"
        echo "  2. Use a cloud Mac service like MacStadium or MacinCloud"
        echo "  3. Access a physical Mac computer"
        echo ""
        return
    fi
    
    read -p "Do you have an Apple Developer account? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Creating account..."
        open_url "https://developer.apple.com/programs/enroll/"
        echo ""
        echo "Please complete the enrollment process ($99/year) and come back."
        read -p "Press Enter when you have your account ready..."
    fi
    
    echo ""
    echo "Step 1: Configure App Store Connect"
    open_url "https://appstoreconnect.apple.com/"
    echo ""
    echo "In App Store Connect:"
    echo "  1. Create a new app"
    echo "  2. Fill in app information"
    echo "  3. Create an app-specific password for uploading"
    echo ""
    read -p "Press Enter when you've set up the app..."
    
    echo ""
    echo "Step 2: Building iOS app..."
    cd tokerrgjik_mobile
    flutter pub get
    
    echo ""
    echo "Opening Xcode to configure signing..."
    open ios/Runner.xcworkspace
    
    echo ""
    echo "In Xcode:"
    echo "  1. Select 'Runner' project"
    echo "  2. Go to 'Signing & Capabilities'"
    echo "  3. Select your Team"
    echo "  4. Configure Bundle Identifier (e.g., com.yourcompany.tokerrgjik)"
    echo "  5. Archive the app: Product > Archive"
    echo "  6. Distribute to App Store"
    echo ""
    read -p "Press Enter when you've completed the Xcode steps..."
    
    echo ""
    echo "Step 3: Submit for Review"
    echo "Back in App Store Connect:"
    echo "  1. Add app screenshots (required for iPhone and iPad)"
    echo "  2. Write app description"
    echo "  3. Set pricing and availability"
    echo "  4. Submit for review"
    echo ""
    echo "Review typically takes 1-3 days."
    
    cd ..
}

case $platform_choice in
    1)
        publish_android
        ;;
    2)
        publish_ios
        ;;
    3)
        publish_android
        publish_ios
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

echo ""
echo "=========================================="
echo "Publishing Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "  - Monitor your app's review status in the developer console"
echo "  - Respond to any review feedback promptly"
echo "  - Prepare marketing materials"
echo "  - Set up app analytics"
echo ""
echo "For automated publishing via CI/CD:"
echo "  - GitHub Actions is already configured in .github/workflows/build-apps.yml"
echo "  - You can create releases by pushing tags: git tag v1.0.0 && git push --tags"
echo ""
