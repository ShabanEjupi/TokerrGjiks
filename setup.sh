#!/bin/bash

# 🎮 Tokerrgjik Interactive Setup Script
# This script helps you configure all necessary API keys and services

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════════════╗"
echo "║                                                          ║"
echo "║        🎮  TOKERRGJIK SETUP WIZARD  🎮                   ║"
echo "║                                                          ║"
echo "║  This wizard will help you configure all services       ║"
echo "║  needed for your game to work properly.                 ║"
echo "║                                                          ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo

# Check if Flutter is installed
echo -e "${YELLOW}Checking prerequisites...${NC}"
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter is not installed. Please install Flutter first.${NC}"
    echo "Visit: https://flutter.dev/docs/get-started/install"
    exit 1
fi

if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js is not installed. Please install Node.js first.${NC}"
    echo "Visit: https://nodejs.org/"
    exit 1
fi

echo -e "${GREEN}✅ Flutter found: $(flutter --version | head -n 1)${NC}"
echo -e "${GREEN}✅ Node.js found: $(node --version)${NC}"
echo

# Main menu
while true; do
    echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}What would you like to configure?${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
    echo "1. 🎯 Google AdMob (Advertising)"
    echo "2. 💳 Stripe (Payments)"
    echo "3. 🐛 Sentry (Error Tracking)"
    echo "4. 🌐 Backend Server URLs"
    echo "5. 📊 Database Configuration"
    echo "6. 📈 Analytics Services"
    echo "7. 🔐 Review Current Configuration"
    echo "8. 🚀 Run Full Setup (Install Dependencies)"
    echo "9. 🏗️  Build & Test Application"
    echo "10. 📱 Generate Signing Keys (Android)"
    echo "0. ❌ Exit"
    echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
    echo -n "Enter your choice: "
    read choice

    case $choice in
        1)
            echo -e "\n${YELLOW}🎯 Google AdMob Setup${NC}"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "To get your AdMob keys:"
            echo "1. Visit: https://admob.google.com/"
            echo "2. Sign in and create a new app"
            echo "3. Get your App ID and Ad Unit IDs"
            echo
            echo -n "Enter your Android AdMob App ID (or press Enter to skip): "
            read admob_android
            echo -n "Enter your iOS AdMob App ID (or press Enter to skip): "
            read admob_ios
            
            if [ ! -z "$admob_android" ] || [ ! -z "$admob_ios" ]; then
                echo -e "${GREEN}✅ AdMob IDs saved! Update them in tokerrgjik_mobile/lib/config/api_keys.dart${NC}"
            fi
            ;;
            
        2)
            echo -e "\n${YELLOW}💳 Stripe Setup${NC}"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "To get your Stripe keys:"
            echo "1. Visit: https://dashboard.stripe.com/register"
            echo "2. Complete registration"
            echo "3. Go to Developers → API keys"
            echo "4. Use TEST keys for development!"
            echo
            echo -n "Enter your Stripe Publishable Key (or press Enter to skip): "
            read stripe_pub
            echo -n "Enter your Stripe Secret Key (or press Enter to skip): "
            read -s stripe_secret
            echo
            
            if [ ! -z "$stripe_pub" ]; then
                echo -e "${GREEN}✅ Stripe keys saved! Update them in tokerrgjik_mobile/lib/config/api_keys.dart${NC}"
                echo -e "${RED}⚠️  IMPORTANT: Never commit your Secret Key to version control!${NC}"
            fi
            ;;
            
        3)
            echo -e "\n${YELLOW}🐛 Sentry Setup${NC}"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "To get your Sentry DSN:"
            echo "1. Visit: https://sentry.io/signup/"
            echo "2. Create a new Flutter project"
            echo "3. Copy the DSN from the setup page"
            echo
            echo -n "Enter your Sentry DSN (or press Enter to skip): "
            read sentry_dsn
            
            if [ ! -z "$sentry_dsn" ]; then
                echo -e "${GREEN}✅ Sentry DSN saved! Update it in tokerrgjik_mobile/lib/config/api_keys.dart${NC}"
            fi
            ;;
            
        4)
            echo -e "\n${YELLOW}🌐 Backend Server Configuration${NC}"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "Current local IP addresses:"
            if [[ "$OSTYPE" == "darwin"* ]] || [[ "$OSTYPE" == "linux-gnu"* ]]; then
                ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print "  - " $2}'
            fi
            echo
            echo "For development:"
            echo "  - Android Emulator: http://10.0.2.2:3000"
            echo "  - Physical Device: http://YOUR_LOCAL_IP:3000"
            echo "  - iOS Simulator: http://localhost:3000"
            echo
            echo -n "Enter your production server URL (or press Enter to skip): "
            read server_url
            
            if [ ! -z "$server_url" ]; then
                echo -e "${GREEN}✅ Server URL saved! Update it in tokerrgjik_mobile/lib/config/api_keys.dart${NC}"
            fi
            ;;
            
        5)
            echo -e "\n${YELLOW}📊 Database Configuration${NC}"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "Free database options with GitHub Education Pack:"
            echo "  1. MongoDB Atlas: https://www.mongodb.com/cloud/atlas"
            echo "  2. PostgreSQL on DigitalOcean"
            echo "  3. Heroku Postgres"
            echo
            echo -n "Enter your database connection URL (or press Enter to skip): "
            read db_url
            
            if [ ! -z "$db_url" ]; then
                echo -e "${GREEN}✅ Database URL saved! Update it in tokerrgjik_mobile/lib/config/api_keys.dart${NC}"
            fi
            ;;
            
        6)
            echo -e "\n${YELLOW}📈 Analytics Services${NC}"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "Available analytics services:"
            echo "  - SimpleAnalytics (privacy-friendly)"
            echo "  - New Relic (performance monitoring)"
            echo "  - Appfigures (app store analytics)"
            echo
            echo "Visit SETUP-GUIDE.md for detailed setup instructions"
            ;;
            
        7)
            echo -e "\n${YELLOW}🔐 Current Configuration${NC}"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            if [ -f "tokerrgjik_mobile/lib/config/api_keys.dart" ]; then
                echo "Configuration file exists: tokerrgjik_mobile/lib/config/api_keys.dart"
                echo
                echo "To view (without showing secrets):"
                grep -E "static const String.*=" tokerrgjik_mobile/lib/config/api_keys.dart | grep -v "//" | head -20
            else
                echo -e "${RED}❌ Configuration file not found!${NC}"
            fi
            ;;
            
        8)
            echo -e "\n${YELLOW}🚀 Running Full Setup${NC}"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            
            echo -e "${BLUE}Installing Flutter dependencies...${NC}"
            cd tokerrgjik_mobile
            flutter pub get
            cd ..
            echo -e "${GREEN}✅ Flutter dependencies installed${NC}"
            
            echo -e "${BLUE}Installing Node.js dependencies...${NC}"
            npm install
            echo -e "${GREEN}✅ Node.js dependencies installed${NC}"
            
            echo -e "${BLUE}Running Flutter doctor...${NC}"
            flutter doctor
            
            echo -e "${GREEN}✅ Full setup completed!${NC}"
            ;;
            
        9)
            echo -e "\n${YELLOW}🏗️  Build & Test Application${NC}"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "1. Build Android APK"
            echo "2. Build Android AAB"
            echo "3. Build iOS"
            echo "4. Build Web"
            echo "5. Run on connected device"
            echo "6. Run tests"
            echo "0. Back to main menu"
            echo
            echo -n "Enter your choice: "
            read build_choice
            
            cd tokerrgjik_mobile
            case $build_choice in
                1)
                    echo -e "${BLUE}Building Android APK...${NC}"
                    flutter build apk --release
                    echo -e "${GREEN}✅ APK built: build/app/outputs/flutter-apk/app-release.apk${NC}"
                    ;;
                2)
                    echo -e "${BLUE}Building Android AAB...${NC}"
                    flutter build appbundle --release
                    echo -e "${GREEN}✅ AAB built: build/app/outputs/bundle/release/app-release.aab${NC}"
                    ;;
                3)
                    echo -e "${BLUE}Building iOS...${NC}"
                    flutter build ios --release
                    echo -e "${GREEN}✅ iOS built successfully${NC}"
                    ;;
                4)
                    echo -e "${BLUE}Building Web...${NC}"
                    flutter build web --release
                    echo -e "${GREEN}✅ Web built: build/web/${NC}"
                    ;;
                5)
                    echo -e "${BLUE}Available devices:${NC}"
                    flutter devices
                    echo
                    echo -n "Enter device ID: "
                    read device_id
                    flutter run -d $device_id
                    ;;
                6)
                    echo -e "${BLUE}Running tests...${NC}"
                    flutter test
                    ;;
            esac
            cd ..
            ;;
            
        10)
            echo -e "\n${YELLOW}📱 Generate Android Signing Keys${NC}"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "This will generate a keystore for signing your Android app."
            echo
            echo -n "Enter keystore password: "
            read -s keystore_password
            echo
            echo -n "Enter key alias (default: tokerrgjik): "
            read key_alias
            key_alias=${key_alias:-tokerrgjik}
            
            keytool -genkey -v -keystore ~/tokerrgjik-key.jks \
                -keyalg RSA -keysize 2048 -validity 10000 \
                -alias $key_alias \
                -storepass $keystore_password \
                -keypass $keystore_password
            
            echo -e "${GREEN}✅ Keystore created: ~/tokerrgjik-key.jks${NC}"
            echo
            echo "Add this to tokerrgjik_mobile/android/key.properties:"
            echo "storePassword=$keystore_password"
            echo "keyPassword=$keystore_password"
            echo "keyAlias=$key_alias"
            echo "storeFile=$HOME/tokerrgjik-key.jks"
            ;;
            
        0)
            echo -e "${GREEN}Thanks for using Tokerrgjik Setup Wizard! 🎮${NC}"
            exit 0
            ;;
            
        *)
            echo -e "${RED}Invalid choice. Please try again.${NC}"
            ;;
    esac
    
    echo
    echo -n "Press Enter to continue..."
    read
    echo
done
