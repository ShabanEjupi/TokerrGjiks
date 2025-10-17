#!/bin/bash

# 🚀 Quick Start Script for Tokerrgjik
# Run this first time after cloning the repository

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════════════╗"
echo "║                                                          ║"
echo "║      🎮  TOKERRGJIK QUICK START  🎮                      ║"
echo "║                                                          ║"
echo "║  This script will set up everything you need!           ║"
echo "║                                                          ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo -e "${NC}\n"

# Check prerequisites
echo -e "${YELLOW}📋 Checking prerequisites...${NC}"

if ! command -v node &> /dev/null; then
    echo -e "${YELLOW}❌ Node.js not found. Please install from https://nodejs.org/${NC}"
    exit 1
fi

if ! command -v flutter &> /dev/null; then
    echo -e "${YELLOW}❌ Flutter not found. Please install from https://flutter.dev/${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Node.js found: $(node --version)${NC}"
echo -e "${GREEN}✅ Flutter found: $(flutter --version | head -n 1)${NC}\n"

# Install backend dependencies
echo -e "${BLUE}📦 Installing backend dependencies...${NC}"
npm install
echo -e "${GREEN}✅ Backend dependencies installed${NC}\n"

# Install Flutter dependencies
echo -e "${BLUE}📦 Installing Flutter dependencies...${NC}"
cd tokerrgjik_mobile
flutter pub get
cd ..
echo -e "${GREEN}✅ Flutter dependencies installed${NC}\n"

# Create .env file if it doesn't exist
if [ ! -f ".env" ]; then
    echo -e "${BLUE}📝 Creating .env file...${NC}"
    cp .env.example .env
    echo -e "${GREEN}✅ .env file created${NC}"
    echo -e "${YELLOW}⚠️  Please edit .env and add your database credentials${NC}\n"
else
    echo -e "${GREEN}✅ .env file already exists${NC}\n"
fi

# Check if api_keys.dart needs to be created
if [ ! -f "tokerrgjik_mobile/lib/config/api_keys.dart" ]; then
    echo -e "${YELLOW}⚠️  API keys file not found!${NC}"
    echo -e "${BLUE}📝 Please add your API keys to: tokerrgjik_mobile/lib/config/api_keys.dart${NC}"
    echo -e "${YELLOW}   See SETUP-GUIDE.md for instructions on getting API keys${NC}\n"
else
    echo -e "${GREEN}✅ API keys file exists${NC}\n"
fi

# Run flutter doctor
echo -e "${BLUE}🔍 Running Flutter doctor...${NC}"
cd tokerrgjik_mobile
flutter doctor
cd ..
echo

# Provide next steps
echo -e "${GREEN}"
echo "╔══════════════════════════════════════════════════════════╗"
echo "║                                                          ║"
echo "║           🎉  SETUP COMPLETE!  🎉                        ║"
echo "║                                                          ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo -e "${NC}\n"

echo -e "${BLUE}📋 Next Steps:${NC}\n"

echo -e "${YELLOW}1. Configure API Keys (REQUIRED):${NC}"
echo "   Edit: tokerrgjik_mobile/lib/config/api_keys.dart"
echo "   Add your:"
echo "   - Google AdMob keys (get from https://admob.google.com/)"
echo "   - MongoDB connection string (or use local MongoDB)"
echo ""

echo -e "${YELLOW}2. Start the Backend Server:${NC}"
echo "   ${BLUE}npm start${NC}"
echo ""

echo -e "${YELLOW}3. Run the Flutter App (in a new terminal):${NC}"
echo "   ${BLUE}cd tokerrgjik_mobile${NC}"
echo "   ${BLUE}flutter run${NC}"
echo ""

echo -e "${YELLOW}4. Or use the interactive setup:${NC}"
echo "   ${BLUE}./setup.sh${NC}"
echo ""

echo -e "${GREEN}📖 Documentation:${NC}"
echo "   - README.md - Project overview"
echo "   - SETUP-GUIDE.md - Detailed setup instructions"
echo "   - QUICK-REFERENCE.md - Common commands"
echo "   - FINAL-REPORT.md - Complete feature list"
echo ""

echo -e "${GREEN}🆘 Need help?${NC}"
echo "   Check the documentation or open an issue on GitHub"
echo ""

echo -e "${BLUE}Happy coding! 🚀${NC}"
