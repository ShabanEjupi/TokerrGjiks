#!/bin/bash

# TokerrGjiks Credentials Setup Script
# This script helps you configure all API keys and credentials

echo "🔐 TokerrGjiks Credentials Setup"
echo "================================="
echo ""

# Function to update Dart file
update_dart_config() {
    local file=$1
    local key=$2
    local value=$3
    sed -i "s|${key} = '.*'|${key} = '${value}'|g" "$file"
}

# Function to update HTML file
update_html_config() {
    local file=$1
    local placeholder=$2
    local value=$3
    sed -i "s|${placeholder}|${value}|g" "$file"
}

# PayPal Configuration
echo "📦 1. PayPal Configuration"
echo "─────────────────────────"
read -p "Enter your PayPal Client ID (from developer.paypal.com): " paypal_client_id
read -p "Enter your PayPal Secret Key: " paypal_secret

if [ ! -z "$paypal_client_id" ] && [ ! -z "$paypal_secret" ]; then
    update_dart_config "tokerrgjik_mobile/lib/config/payment_config.dart" "paypalClientId" "$paypal_client_id"
    update_dart_config "tokerrgjik_mobile/lib/config/payment_config.dart" "paypalSecret" "$paypal_secret"
    echo "✅ PayPal credentials configured!"
else
    echo "⚠️  Skipping PayPal configuration (no credentials provided)"
fi
echo ""

# Google AdSense Configuration
echo "📢 2. Google AdSense Configuration"
echo "──────────────────────────────────"
read -p "Enter your AdSense Publisher ID (ca-pub-XXXXXXXXXXXXXXXX): " adsense_publisher_id
read -p "Enter your Ad Slot ID for top banner: " adsense_slot_top
read -p "Enter your Ad Slot ID for bottom banner: " adsense_slot_bottom

if [ ! -z "$adsense_publisher_id" ]; then
    # Uncomment AdSense code in HTML
    sed -i 's|<!-- \(.*adsbygoogle.*\) -->|\1|g' tokerrgjik_mobile/web/index.html
    
    # Replace publisher ID
    update_html_config "tokerrgjik_mobile/web/index.html" "ca-pub-XXXXXXXXXXXXXXXX" "$adsense_publisher_id"
    
    if [ ! -z "$adsense_slot_top" ]; then
        sed -i "s|YOUR_AD_SLOT_ID|$adsense_slot_top|" tokerrgjik_mobile/web/index.html
    fi
    
    echo "✅ Google AdSense configured!"
else
    echo "⚠️  Skipping AdSense configuration (no Publisher ID provided)"
fi
echo ""

# Socket.IO Server URL
echo "🌐 3. Socket.IO Server Configuration"
echo "────────────────────────────────────"
read -p "Enter your Socket.IO server URL (e.g., https://your-app.onrender.com): " socketio_url

if [ ! -z "$socketio_url" ]; then
    update_dart_config "tokerrgjik_mobile/lib/services/socket_service_realtime.dart" "final url = serverUrl ??" "$socketio_url"
    echo "✅ Socket.IO server URL configured!"
else
    echo "⚠️  Skipping Socket.IO configuration (no URL provided)"
fi
echo ""

# SendGrid Email
echo "📧 4. SendGrid Email Configuration"
echo "───────────────────────────────────"
read -p "Enter your SendGrid API Key (optional): " sendgrid_key

if [ ! -z "$sendgrid_key" ]; then
    # Add to Netlify environment (user needs to do this manually)
    echo "⚠️  Please add this to Netlify manually:"
    echo "   - Go to: Site Settings → Environment Variables"
    echo "   - Add: SENDGRID_API_KEY = $sendgrid_key"
    echo "✅ SendGrid key ready (add to Netlify dashboard)"
else
    echo "⚠️  Skipping SendGrid configuration"
fi
echo ""

# Cloudinary (for avatars)
echo "🖼️  5. Cloudinary Configuration (for avatars)"
echo "──────────────────────────────────────────────"
read -p "Enter your Cloudinary Cloud Name (optional): " cloudinary_name
read -p "Enter your Cloudinary Upload Preset (optional): " cloudinary_preset

if [ ! -z "$cloudinary_name" ] && [ ! -z "$cloudinary_preset" ]; then
    update_dart_config "tokerrgjik_mobile/lib/services/avatar_service.dart" "YOUR_CLOUD_NAME" "$cloudinary_name"
    update_dart_config "tokerrgjik_mobile/lib/services/avatar_service.dart" "YOUR_UPLOAD_PRESET" "$cloudinary_preset"
    echo "✅ Cloudinary configured!"
else
    echo "⚠️  Skipping Cloudinary configuration"
fi
echo ""

# Summary
echo "═══════════════════════════════════════"
echo "✅ Configuration Complete!"
echo "═══════════════════════════════════════"
echo ""
echo "📋 Next Steps:"
echo "1. Build Flutter web: cd tokerrgjik_mobile && flutter build web --release"
echo "2. Commit changes: git add -A && git commit -m 'Configure credentials'"
echo "3. Push to GitHub: git push origin main"
echo "4. Deploy Socket.IO server to Render.com"
echo "5. Add SENDGRID_API_KEY to Netlify environment variables"
echo ""
echo "📚 Read ADVANCED_FEATURES_GUIDE.md for detailed instructions"
echo ""
