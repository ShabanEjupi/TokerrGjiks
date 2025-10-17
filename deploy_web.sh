#!/bin/bash

# Web Deployment Helper Script
# This script helps you deploy the Flutter web build to Netlify or Vercel

echo "=========================================="
echo "TokerrGjiks - Web Deployment Helper"
echo "=========================================="
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "Error: Flutter is not installed!"
    echo "Please install Flutter first: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Build the web app
echo "Building Flutter web app..."
cd tokerrgjik_mobile
flutter pub get
flutter build web --release

if [ $? -ne 0 ]; then
    echo "Error: Flutter build failed!"
    exit 1
fi

cd ..

echo ""
echo "✓ Web app built successfully!"
echo ""
echo "Build output is located at: tokerrgjik_mobile/build/web/"
echo ""

# Ask for deployment platform
echo "Choose deployment platform:"
echo "1) Netlify"
echo "2) Vercel"
echo "3) Exit (I'll deploy manually)"
echo ""
read -p "Enter your choice (1-3): " choice

case $choice in
    1)
        echo ""
        echo "Deploying to Netlify..."
        echo ""
        
        # Check if Netlify CLI is installed
        if ! command -v netlify &> /dev/null; then
            echo "Netlify CLI not found. Installing..."
            npm install -g netlify-cli
        fi
        
        echo "Please log in to Netlify:"
        netlify login
        
        echo ""
        read -p "Do you want to create a new site or deploy to existing? (new/existing): " site_choice
        
        if [ "$site_choice" = "new" ]; then
            echo "Creating new Netlify site..."
            netlify deploy --dir=tokerrgjik_mobile/build/web --prod
        else
            echo "Deploying to existing site..."
            netlify deploy --dir=tokerrgjik_mobile/build/web --prod
        fi
        
        echo ""
        echo "✓ Deployment complete!"
        ;;
        
    2)
        echo ""
        echo "Deploying to Vercel..."
        echo ""
        
        # Check if Vercel CLI is installed
        if ! command -v vercel &> /dev/null; then
            echo "Vercel CLI not found. Installing..."
            npm install -g vercel
        fi
        
        echo "Please log in to Vercel:"
        vercel login
        
        echo ""
        echo "Deploying..."
        cd tokerrgjik_mobile/build/web
        vercel --prod
        
        cd ../../..
        
        echo ""
        echo "✓ Deployment complete!"
        ;;
        
    3)
        echo ""
        echo "Manual deployment instructions:"
        echo ""
        echo "The built web app is in: tokerrgjik_mobile/build/web/"
        echo ""
        echo "For Netlify:"
        echo "  1. Visit: https://app.netlify.com/"
        echo "  2. Drag and drop the 'tokerrgjik_mobile/build/web' folder"
        echo "  3. Your site will be live in seconds!"
        echo ""
        echo "For Vercel:"
        echo "  1. Visit: https://vercel.com/"
        echo "  2. Import your GitHub repository"
        echo "  3. Set build command: cd tokerrgjik_mobile && flutter build web"
        echo "  4. Set output directory: tokerrgjik_mobile/build/web"
        echo ""
        echo "For Firebase Hosting:"
        echo "  1. Install Firebase CLI: npm install -g firebase-tools"
        echo "  2. Run: firebase login"
        echo "  3. Run: firebase init hosting"
        echo "  4. Set public directory: tokerrgjik_mobile/build/web"
        echo "  5. Run: firebase deploy"
        echo ""
        ;;
        
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

echo ""
echo "=========================================="
echo "Deployment Info"
echo "=========================================="
echo ""
echo "Your Flutter web app has been deployed!"
echo ""
echo "Important notes:"
echo "  - Make sure to configure your API keys before deployment"
echo "  - Update the backend URL in api_keys.dart if using multiplayer features"
echo "  - Test the deployed app thoroughly before sharing"
echo ""
