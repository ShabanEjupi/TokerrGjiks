import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/api_keys.dart';

/// AdService for displaying Google Mobile Ads
/// Strategically placed to not interfere with gameplay
class AdService {
  static bool _isInitialized = false;
  static BannerAd? _homeBannerAd;
  static BannerAd? _gameOverBannerAd;
  static InterstitialAd? _interstitialAd;
  static RewardedAd? _rewardedAd;
  static int _gameCount = 0;

  /// Initialize the Google Mobile Ads SDK
  static Future<void> initialize() async {
    if (kIsWeb) {
      // Google Mobile Ads doesn't work on web
      print('AdService: Skipping initialization on web platform');
      return;
    }
    
    if (!_isInitialized) {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      print('AdService: Google Mobile Ads initialized');
      // Preload ads
      loadInterstitialAd();
      loadRewardedAd();
    }
  }

  /// Get Banner Ad Unit ID (platform-specific)
  /// Uses API keys from configuration
  static String get bannerAdUnitId {
    if (kIsWeb) return '';
    
    if (Platform.isAndroid) {
      return ApiKeys.admobBannerAndroid;
    } else if (Platform.isIOS) {
      return ApiKeys.admobBannerIos;
    }
    return '';
  }

  /// Get Interstitial Ad Unit ID
  static String get interstitialAdUnitId {
    if (kIsWeb) return '';
    
    if (Platform.isAndroid) {
      return ApiKeys.admobInterstitialAndroid;
    } else if (Platform.isIOS) {
      return ApiKeys.admobInterstitialIos;
    }
    return '';
  }

  /// Get Rewarded Ad Unit ID
  static String get rewardedAdUnitId {
    if (kIsWeb) return '';
    
    if (Platform.isAndroid) {
      return ApiKeys.admobRewardedAndroid;
    } else if (Platform.isIOS) {
      return ApiKeys.admobRewardedIos;
    }
    return '';
  }

  /// Create a banner ad for home screen (bottom placement)
  static BannerAd? createHomeBannerAd() {
    if (kIsWeb) return null;
    
    if (_homeBannerAd != null) {
      return _homeBannerAd;
    }

    _homeBannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('Home Banner Ad loaded.');
        },
        onAdFailedToLoad: (ad, error) {
          print('Home Banner Ad failed to load: $error');
          ad.dispose();
          _homeBannerAd = null;
        },
      ),
    );

    _homeBannerAd!.load();
    return _homeBannerAd;
  }

  /// Create a banner ad for game over dialog
  static BannerAd? createGameOverBannerAd() {
    if (kIsWeb) return null;
    
    if (_gameOverBannerAd != null) {
      return _gameOverBannerAd;
    }

    _gameOverBannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.mediumRectangle,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('Game Over Banner Ad loaded.');
        },
        onAdFailedToLoad: (ad, error) {
          print('Game Over Banner Ad failed to load: $error');
          ad.dispose();
          _gameOverBannerAd = null;
        },
      ),
    );

    _gameOverBannerAd!.load();
    return _gameOverBannerAd;
  }

  /// Load interstitial ad (shown after every 3 games to avoid annoyance)
  static void loadInterstitialAd() {
    if (kIsWeb) return;
    
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          print('Interstitial Ad loaded.');
        },
        onAdFailedToLoad: (error) {
          print('Interstitial Ad failed to load: $error');
          _interstitialAd = null;
        },
      ),
    );
  }

  /// Show interstitial ad if game count threshold reached (every 3 games)
  static void showInterstitialAdIfReady() {
    if (kIsWeb) return;
    
    _gameCount++;
    if (_gameCount % 3 == 0 && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _interstitialAd = null;
          loadInterstitialAd(); // Preload next ad
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          print('Interstitial Ad failed to show: $error');
          ad.dispose();
          _interstitialAd = null;
          loadInterstitialAd();
        },
      );
      _interstitialAd!.show();
    } else if (_interstitialAd == null) {
      loadInterstitialAd(); // Ensure ad is loading
    }
  }

  /// Load rewarded ad for extra features
  static void loadRewardedAd() {
    if (kIsWeb) return;
    
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          print('Rewarded Ad loaded.');
        },
        onAdFailedToLoad: (error) {
          print('Rewarded Ad failed to load: $error');
          _rewardedAd = null;
        },
      ),
    );
  }

  /// Show rewarded ad with callback (for earning coins, hints, etc.)
  static void showRewardedAd(Function(int coins) onRewarded) {
    if (kIsWeb) {
      print('Rewarded ads not supported on web');
      return;
    }
    
    if (_rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _rewardedAd = null;
          loadRewardedAd(); // Preload next ad
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          print('Rewarded Ad failed to show: $error');
          ad.dispose();
          _rewardedAd = null;
          loadRewardedAd();
        },
      );
      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          print('User earned reward: ${reward.amount} ${reward.type}');
          onRewarded(2); // Give 2 points reward
        },
      );
    } else {
      print('Rewarded Ad not ready yet.');
      loadRewardedAd();
    }
  }

  /// Check if rewarded ad is ready
  static bool get isRewardedAdReady => kIsWeb ? false : _rewardedAd != null;

  /// Dispose banner ads
  static void disposeHomeBannerAd() {
    _homeBannerAd?.dispose();
    _homeBannerAd = null;
  }

  static void disposeGameOverBannerAd() {
    _gameOverBannerAd?.dispose();
    _gameOverBannerAd = null;
  }

  /// Dispose all ads
  static void disposeAll() {
    _homeBannerAd?.dispose();
    _gameOverBannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _homeBannerAd = null;
    _gameOverBannerAd = null;
    _interstitialAd = null;
    _rewardedAd = null;
  }
}
