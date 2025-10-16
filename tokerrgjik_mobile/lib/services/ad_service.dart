import 'package:flutter/foundation.dart';

/// Stub implementation of AdService
/// This version does NOT require google_mobile_ads package or AdMob App ID
/// 
/// TO ENABLE REAL ADS:
/// 1. Add google_mobile_ads to pubspec.yaml
/// 2. Add your AdMob App ID to AndroidManifest.xml
/// 3. Replace this stub with the real implementation
class AdService {
  bool _isRewardedAdReady = false;

  /// Initialize the ad service (stub - does nothing)
  static Future<void> initialize() async {
    if (kDebugMode) {
      print('AdService: Stub implementation - no real ads will be shown');
    }
  }

  /// Load a rewarded ad (stub - simulates loading)
  void loadRewardedAd() {
    if (kDebugMode) {
      print('AdService: Loading rewarded ad (stub)...');
    }
    // Simulate ad being ready after a delay
    Future.delayed(const Duration(seconds: 1), () {
      _isRewardedAdReady = true;
      if (kDebugMode) {
        print('AdService: Rewarded ad ready (stub)');
      }
    });
  }

  /// Check if a rewarded ad is ready to show
  bool get isRewardedAdReady => kDebugMode; // Always ready in debug mode

  /// Show a rewarded ad (stub - gives test reward immediately)
  void showRewardedAd({
    required Function(int coins) onRewarded,
  }) {
    if (kDebugMode) {
      print('AdService: Showing rewarded ad (stub)...');
      // Give test reward immediately in debug mode
      Future.delayed(const Duration(milliseconds: 500), () {
        if (kDebugMode) {
          print('AdService: Ad completed, giving test reward');
        }
        onRewarded(100); // Give 100 test coins
        // Reload ad for next time
        loadRewardedAd();
      });
    } else {
      // In release mode, do nothing (no ads configured)
      if (kDebugMode) {
        print('AdService: Ads not available in release mode without configuration');
      }
    }
  }

  /// Dispose of resources (stub - does nothing)
  void dispose() {
    if (kDebugMode) {
      print('AdService: Disposing (stub)');
    }
  }
}
