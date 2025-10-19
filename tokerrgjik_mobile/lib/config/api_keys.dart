/// API Keys Configuration
/// This file contains all API keys and sensitive configuration
/// DO NOT commit this file to version control with real keys
/// 
/// Setup Instructions:
/// 1. Copy this file to api_keys.dart (already done)
/// 2. Replace the placeholder values with your actual API keys
/// 3. Add api_keys.dart to .gitignore to keep your keys secure

class ApiKeys {
  //neon database
  static const String neonDatabaseUrl = 'postgresql://neondb_owner:npg_d6WqxY0NaMnR@ep-super-water-aedl5ojl-pooler.c-2.us-east-2.aws.neon.tech/neondb?channel_binding=require&sslmode=require';
  static const String neonDatabaseUrlUnpooled = 'postgresql://neondb_owner:npg_d6WqxY0NaMnR@ep-super-water-aedl5ojl.c-2.us-east-2.aws.neon.tech/neondb?channel_binding=require&sslmode=require';

  // ==================== ADMOB ====================
  /// Get your AdMob App IDs from: https://apps.admob.google.com/
  /// Create an account, add your app, and get the App ID
  static const String admobAppIdAndroid = 'ca-app-pub-8491001524308476~9753001043';
  static const String admobAppIdIos = 'ca-app-pub-8491001524308476~5326670873';
  
  /// AdMob Ad Unit IDs (create these in AdMob console)
  static const String admobBannerAndroid = 'ca-app-pub-8491001524308476/7116257088'; // Test ID - Replace with yours
  static const String admobBannerIos = 'ca-app-pub-8491001524308476/4681665438'; // Test ID - Replace with yours
  
  static const String admobInterstitialAndroid = 'ca-app-pub-8491001524308476/9581997693'; // Test ID
  static const String admobInterstitialIos = 'ca-app-pub-8491001524308476/5179718251'; // Test ID
  
  static const String admobRewardedAndroid = 'ca-app-pub-8491001524308476/8248347684'; // Test ID
  static const String admobRewardedIos = 'ca-app-pub-8491001524308476/3041280706'; // Test ID

  // ==================== STRIPE ====================
  /// Get your Stripe keys from: https://dashboard.stripe.com/apikeys
  /// Use test keys for development, production keys for release
  static const String stripePublishableKey = 'pk_test_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'; // TODO: Replace
  static const String stripeSecretKey = 'sk_test_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'; // TODO: Replace (Keep this secret!)

  // ==================== SENTRY ====================
  /// Get your Sentry DSN from: https://sentry.io/
  /// Create a project and copy the DSN
  static const String sentryDsn = 'https://XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX@oXXXXXX.ingest.sentry.io/XXXXXXX'; // TODO: Replace

  // ==================== BACKEND SERVER ====================
  /// Your backend server URL
  /// Development: Use your local IP or ngrok URL
  /// Production: Use your deployed server URL (DigitalOcean, Heroku, etc.)
  static const String serverUrl = 'http://10.0.2.2:3000'; // Android emulator localhost
  static const String serverUrlProduction = 'https://your-app.digitalocean.app'; // TODO: Replace
  
  /// WebSocket URL for real-time multiplayer
  static const String websocketUrl = 'ws://10.0.2.2:3000';
  static const String websocketUrlProduction = 'wss://your-app.digitalocean.app';

  // ==================== DATABASE ====================
  /// PostgreSQL/MongoDB connection (for backend)
  /// Get free databases from GitHub Education Pack
  static const String databaseUrl = 'postgresql://user:password@host:5432/tokerrgjik'; // TODO: Replace
  static const String mongoDbUrl = 'mongodb://user:password@host:27017/tokerrgjik'; // TODO: Replace

  // ==================== ANALYTICS ====================
  /// SimpleAnalytics Site ID (privacy-friendly analytics)
  static const String simpleAnalyticsSiteId = 'your-site-id'; // TODO: Replace
  
  /// New Relic License Key
  static const String newRelicLicenseKey = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'; // TODO: Replace

  // ==================== OTHER SERVICES ====================
  /// Icons8 API Key (if using their API)
  static const String icons8ApiKey = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'; // TODO: Replace
  
  /// DevCycle SDK Key
  static const String devCycleSdkKey = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'; // TODO: Replace
  
  /// Blockchair API Key (for blockchain features)
  static const String blockchairApiKey = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'; // TODO: Replace

  // ==================== HELPERS ====================
  
  /// Check if running in development mode
  static bool get isDevelopment {
    return serverUrl.contains('10.0.2.2') || serverUrl.contains('localhost');
  }
  
  /// Get appropriate server URL based on environment
  static String get currentServerUrl {
    return isDevelopment ? serverUrl : serverUrlProduction;
  }
  
  /// Get appropriate WebSocket URL based on environment
  static String get currentWebsocketUrl {
    return isDevelopment ? websocketUrl : websocketUrlProduction;
  }
}
