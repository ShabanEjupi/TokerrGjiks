import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

/// Local Storage Service using SharedPreferences
/// Saves user data, stats, and settings to device storage
class StorageService {
  static const String _keyUserProfile = 'user_profile';
  static const String _keyGameStats = 'game_stats';
  static const String _keySettings = 'settings';
  static const String _keyCoins = 'coins';
  static const String _keyHighScore = 'high_score';
  static const String _keyGamesPlayed = 'games_played';
  static const String _keyGamesWon = 'games_won';
  static const String _keyTotalPlayTime = 'total_play_time';

  static SharedPreferences? _prefs;

  /// Initialize SharedPreferences
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    print('StorageService: Initialized');
  }

  /// Get SharedPreferences instance
  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('StorageService not initialized. Call initialize() first.');
    }
    return _prefs!;
  }

  // ==================== USER PROFILE ====================

  /// Save user profile
  static Future<bool> saveUserProfile(UserProfile profile) async {
    try {
      final json = jsonEncode(profile.toJson());
      return await prefs.setString(_keyUserProfile, json);
    } catch (e) {
      print('Error saving user profile: $e');
      return false;
    }
  }

  /// Load user profile
  static UserProfile? loadUserProfile() {
    try {
      final json = prefs.getString(_keyUserProfile);
      if (json != null) {
        final map = jsonDecode(json) as Map<String, dynamic>;
        return UserProfile.fromJson(map);
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }
    return null;
  }

  /// Delete user profile
  static Future<bool> deleteUserProfile() async {
    return await prefs.remove(_keyUserProfile);
  }

  // ==================== GAME STATS ====================

  /// Save game statistics
  static Future<bool> saveGameStats(Map<String, dynamic> stats) async {
    try {
      final json = jsonEncode(stats);
      return await prefs.setString(_keyGameStats, json);
    } catch (e) {
      print('Error saving game stats: $e');
      return false;
    }
  }

  /// Load game statistics
  static Map<String, dynamic>? loadGameStats() {
    try {
      final json = prefs.getString(_keyGameStats);
      if (json != null) {
        return jsonDecode(json) as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error loading game stats: $e');
    }
    return null;
  }

  /// Increment games played counter
  static Future<void> incrementGamesPlayed() async {
    int count = prefs.getInt(_keyGamesPlayed) ?? 0;
    await prefs.setInt(_keyGamesPlayed, count + 1);
  }

  /// Get games played count
  static int getGamesPlayed() {
    return prefs.getInt(_keyGamesPlayed) ?? 0;
  }

  /// Increment games won counter
  static Future<void> incrementGamesWon() async {
    int count = prefs.getInt(_keyGamesWon) ?? 0;
    await prefs.setInt(_keyGamesWon, count + 1);
  }

  /// Get games won count
  static int getGamesWon() {
    return prefs.getInt(_keyGamesWon) ?? 0;
  }

  /// Add play time (in seconds)
  static Future<void> addPlayTime(int seconds) async {
    int total = prefs.getInt(_keyTotalPlayTime) ?? 0;
    await prefs.setInt(_keyTotalPlayTime, total + seconds);
  }

  /// Get total play time (in seconds)
  static int getTotalPlayTime() {
    return prefs.getInt(_keyTotalPlayTime) ?? 0;
  }

  // ==================== COINS & REWARDS ====================

  /// Save coins
  static Future<bool> saveCoins(int coins) async {
    return await prefs.setInt(_keyCoins, coins);
  }

  /// Get coins
  static int getCoins() {
    return prefs.getInt(_keyCoins) ?? 0;
  }

  /// Add coins
  static Future<bool> addCoins(int amount) async {
    int current = getCoins();
    return await saveCoins(current + amount);
  }

  /// Subtract coins
  static Future<bool> subtractCoins(int amount) async {
    int current = getCoins();
    if (current >= amount) {
      return await saveCoins(current - amount);
    }
    return false; // Not enough coins
  }

  // ==================== HIGH SCORE ====================

  /// Save high score
  static Future<bool> saveHighScore(int score) async {
    return await prefs.setInt(_keyHighScore, score);
  }

  /// Get high score
  static int getHighScore() {
    return prefs.getInt(_keyHighScore) ?? 0;
  }

  /// Update high score if current is higher
  static Future<bool> updateHighScoreIfBetter(int score) async {
    int current = getHighScore();
    if (score > current) {
      return await saveHighScore(score);
    }
    return false;
  }

  // ==================== SETTINGS ====================

  /// Save app settings
  static Future<bool> saveSettings(Map<String, dynamic> settings) async {
    try {
      final json = jsonEncode(settings);
      return await prefs.setString(_keySettings, json);
    } catch (e) {
      print('Error saving settings: $e');
      return false;
    }
  }

  /// Load app settings
  static Map<String, dynamic>? loadSettings() {
    try {
      final json = prefs.getString(_keySettings);
      if (json != null) {
        return jsonDecode(json) as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error loading settings: $e');
    }
    return null;
  }

  /// Save individual setting
  static Future<bool> saveSetting(String key, dynamic value) async {
    try {
      if (value is String) {
        return await prefs.setString(key, value);
      } else if (value is int) {
        return await prefs.setInt(key, value);
      } else if (value is double) {
        return await prefs.setDouble(key, value);
      } else if (value is bool) {
        return await prefs.setBool(key, value);
      }
    } catch (e) {
      print('Error saving setting $key: $e');
    }
    return false;
  }

  /// Get individual setting
  static dynamic getSetting(String key, {dynamic defaultValue}) {
    return prefs.get(key) ?? defaultValue;
  }

  /// Check if sound is enabled
  static bool isSoundEnabled() {
    return prefs.getBool('sound_enabled') ?? true;
  }

  /// Toggle sound
  static Future<bool> toggleSound() async {
    bool current = isSoundEnabled();
    return await prefs.setBool('sound_enabled', !current);
  }

  // ==================== UTILITY METHODS ====================

  /// Clear all data (for reset/logout)
  static Future<bool> clearAll() async {
    return await prefs.clear();
  }

  /// Clear only game data (keep settings)
  static Future<void> clearGameData() async {
    await prefs.remove(_keyUserProfile);
    await prefs.remove(_keyGameStats);
    await prefs.remove(_keyCoins);
    await prefs.remove(_keyHighScore);
    await prefs.remove(_keyGamesPlayed);
    await prefs.remove(_keyGamesWon);
    await prefs.remove(_keyTotalPlayTime);
  }

  /// Check if this is first launch
  static bool isFirstLaunch() {
    return prefs.getBool('first_launch') ?? true;
  }

  /// Set first launch flag to false
  static Future<void> setNotFirstLaunch() async {
    await prefs.setBool('first_launch', false);
  }

  /// Save last played date
  static Future<void> saveLastPlayedDate() async {
    await prefs.setString('last_played', DateTime.now().toIso8601String());
  }

  /// Get last played date
  static DateTime? getLastPlayedDate() {
    String? dateStr = prefs.getString('last_played');
    if (dateStr != null) {
      try {
        return DateTime.parse(dateStr);
      } catch (e) {
        print('Error parsing last played date: $e');
      }
    }
    return null;
  }
}
