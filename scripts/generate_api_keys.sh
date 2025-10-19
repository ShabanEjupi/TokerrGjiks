#!/bin/bash#!/bin/bash

# Simple script to verify API keys exist

# The actual api_keys.dart file is already committed to the repo# Script to generate api_keys.dart from environment variables or template

# This is used in CI/CD to create the API keys file securely

if [ -f "tokerrgjik_mobile/lib/config/api_keys.dart" ]; then

    echo "✅ API keys file found"API_KEYS_FILE="tokerrgjik_mobile/lib/config/api_keys.dart"

    echo "✅ Build can proceed"

    exit 0# Check if running in CI

elseif [ -n "$CI" ]; then

    echo "❌ Error: api_keys.dart not found!"    echo "🔑 Generating API keys for CI environment..."

    exit 1    

fi    # Use environment variables if available, otherwise use test values

    ADMOB_APP_ID_ANDROID="${ADMOB_APP_ID_ANDROID:-ca-app-pub-3940256099942544~3347511713}"
    ADMOB_APP_ID_IOS="${ADMOB_APP_ID_IOS:-ca-app-pub-3940256099942544~1458002511}"
    ADMOB_BANNER_ANDROID="${ADMOB_BANNER_ANDROID:-ca-app-pub-3940256099942544/6300978111}"
    ADMOB_BANNER_IOS="${ADMOB_BANNER_IOS:-ca-app-pub-3940256099942544/2934735716}"
    ADMOB_INTERSTITIAL_ANDROID="${ADMOB_INTERSTITIAL_ANDROID:-ca-app-pub-3940256099942544/1033173712}"
    ADMOB_INTERSTITIAL_IOS="${ADMOB_INTERSTITIAL_IOS:-ca-app-pub-3940256099942544/4411468910}"
    ADMOB_REWARDED_ANDROID="${ADMOB_REWARDED_ANDROID:-ca-app-pub-3940256099942544/5224354917}"
    ADMOB_REWARDED_IOS="${ADMOB_REWARDED_IOS:-ca-app-pub-3940256099942544/1712485313}"
    
    STRIPE_PUBLISHABLE_KEY="${STRIPE_PUBLISHABLE_KEY:-pk_test_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX}"
    STRIPE_SECRET_KEY="${STRIPE_SECRET_KEY:-sk_test_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX}"
    SENTRY_DSN="${SENTRY_DSN:-https://XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX@oXXXXXX.ingest.sentry.io/XXXXXXX}"
    SERVER_URL="${SERVER_URL:-http://10.0.2.2:3000}"
    SERVER_URL_PROD="${SERVER_URL_PROD:-https://your-app.digitalocean.app}"
    WEBSOCKET_URL="${WEBSOCKET_URL:-ws://10.0.2.2:3000}"
    WEBSOCKET_URL_PROD="${WEBSOCKET_URL_PROD:-wss://your-app.digitalocean.app}"
    DATABASE_URL="${DATABASE_URL:-postgresql://user:password@host:5432/tokerrgjik}"
    MONGODB_URL="${MONGODB_URL:-mongodb://user:password@host:27017/tokerrgjik}"
    SIMPLE_ANALYTICS_SITE_ID="${SIMPLE_ANALYTICS_SITE_ID:-your-site-id}"
    NEW_RELIC_LICENSE_KEY="${NEW_RELIC_LICENSE_KEY:-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX}"
    ICONS8_API_KEY="${ICONS8_API_KEY:-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX}"
    DEVCYCLE_SDK_KEY="${DEVCYCLE_SDK_KEY:-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX}"
    BLOCKCHAIR_API_KEY="${BLOCKCHAIR_API_KEY:-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX}"
else
    echo "📝 Local development - copying from template..."
    # In local development, use the template
    if [ ! -f "$API_KEYS_FILE" ]; then
        cp "${API_KEYS_FILE}.template" "$API_KEYS_FILE"
        echo "✅ Created $API_KEYS_FILE from template"
        echo "⚠️  Please edit $API_KEYS_FILE and add your API keys"
        exit 0
    else
        echo "✅ $API_KEYS_FILE already exists"
        exit 0
    fi
fi

# Generate the api_keys.dart file
cat > "$API_KEYS_FILE" << EOF
/// API Keys Configuration
/// This file is auto-generated for CI/CD
/// DO NOT commit this file to version control with real keys

class ApiKeys {
  // ==================== ADMOB ====================
  static const String admobAppIdAndroid = '$ADMOB_APP_ID_ANDROID';
  static const String admobAppIdIos = '$ADMOB_APP_ID_IOS';
  
  static const String admobBannerAndroid = '$ADMOB_BANNER_ANDROID';
  static const String admobBannerIos = '$ADMOB_BANNER_IOS';
  
  static const String admobInterstitialAndroid = '$ADMOB_INTERSTITIAL_ANDROID';
  static const String admobInterstitialIos = '$ADMOB_INTERSTITIAL_IOS';
  
  static const String admobRewardedAndroid = '$ADMOB_REWARDED_ANDROID';
  static const String admobRewardedIos = '$ADMOB_REWARDED_IOS';

  // ==================== STRIPE ====================
  static const String stripePublishableKey = '$STRIPE_PUBLISHABLE_KEY';
  static const String stripeSecretKey = '$STRIPE_SECRET_KEY';

  // ==================== SENTRY ====================
  static const String sentryDsn = '$SENTRY_DSN';

  // ==================== BACKEND SERVER ====================
  static const String serverUrl = '$SERVER_URL';
  static const String serverUrlProduction = '$SERVER_URL_PROD';
  
  static const String websocketUrl = '$WEBSOCKET_URL';
  static const String websocketUrlProduction = '$WEBSOCKET_URL_PROD';

  // ==================== DATABASE ====================
  static const String databaseUrl = '$DATABASE_URL';
  static const String mongoDbUrl = '$MONGODB_URL';

  // ==================== ANALYTICS ====================
  static const String simpleAnalyticsSiteId = '$SIMPLE_ANALYTICS_SITE_ID';
  static const String newRelicLicenseKey = '$NEW_RELIC_LICENSE_KEY';

  // ==================== OTHER SERVICES ====================
  static const String icons8ApiKey = '$ICONS8_API_KEY';
  static const String devCycleSdkKey = '$DEVCYCLE_SDK_KEY';
  static const String blockchairApiKey = '$BLOCKCHAIR_API_KEY';

  // ==================== HELPERS ====================
  static bool get isDevelopment {
    return serverUrl.contains('10.0.2.2') || serverUrl.contains('localhost');
  }
  
  static String get currentServerUrl {
    return isDevelopment ? serverUrl : serverUrlProduction;
  }
  
  static String get currentWebsocketUrl {
    return isDevelopment ? websocketUrl : websocketUrlProduction;
  }
}
EOF

echo "✅ Generated $API_KEYS_FILE for CI/CD"
