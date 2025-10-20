import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Local Storage Service using SharedPreferences
/// 
/// Stores user data locally on the device for offline access
/// This is used for mobile app (APK/iOS) when not connected to web database
class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  SharedPreferences? _prefs;

  /// Initialize shared preferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('LocalStorageService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // ===== User Data =====

  /// Save current user data
  Future<bool> saveUser(Map<String, dynamic> userData) async {
    return await prefs.setString('current_user', jsonEncode(userData));
  }

  /// Get current user data
  Map<String, dynamic>? getUser() {
    final userJson = prefs.getString('current_user');
    if (userJson == null) return null;
    return jsonDecode(userJson);
  }

  /// Clear user data (logout)
  Future<bool> clearUser() async {
    return await prefs.remove('current_user');
  }

  /// Update user stats
  Future<bool> updateUserStats({
    int? wins,
    int? losses,
    int? draws,
    int? coins,
    int? xp,
    int? level,
  }) async {
    final user = getUser();
    if (user == null) return false;

    if (wins != null) user['total_wins'] = (user['total_wins'] ?? 0) + wins;
    if (losses != null) user['total_losses'] = (user['total_losses'] ?? 0) + losses;
    if (draws != null) user['total_draws'] = (user['total_draws'] ?? 0) + draws;
    if (coins != null) user['coins'] = (user['coins'] ?? 0) + coins;
    if (xp != null) user['xp'] = (user['xp'] ?? 0) + xp;
    if (level != null) user['level'] = level;

    return await saveUser(user);
  }

  /// Update Pro status
  Future<bool> updateProStatus(bool isPro, DateTime? expiresAt) async {
    final user = getUser();
    if (user == null) return false;

    user['is_pro'] = isPro;
    user['pro_expires_at'] = expiresAt?.toIso8601String();

    return await saveUser(user);
  }

  // ===== Game History =====

  /// Save game history
  Future<bool> saveGameHistory(Map<String, dynamic> gameData) async {
    final history = getGameHistory();
    history.add(gameData);

    // Keep only last 100 games
    if (history.length > 100) {
      history.removeAt(0);
    }

    return await prefs.setString('game_history', jsonEncode(history));
  }

  /// Get game history
  List<Map<String, dynamic>> getGameHistory() {
    final historyJson = prefs.getString('game_history');
    if (historyJson == null) return [];
    final List<dynamic> decoded = jsonDecode(historyJson);
    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  // ===== Settings =====

  /// Save game settings
  Future<bool> saveSetting(String key, dynamic value) async {
    if (value is bool) {
      return await prefs.setBool(key, value);
    } else if (value is int) {
      return await prefs.setInt(key, value);
    } else if (value is double) {
      return await prefs.setDouble(key, value);
    } else if (value is String) {
      return await prefs.setString(key, value);
    }
    return false;
  }

  /// Get setting value
  dynamic getSetting(String key, {dynamic defaultValue}) {
    if (prefs.containsKey(key)) {
      return prefs.get(key);
    }
    return defaultValue;
  }

  // ===== Authentication Token =====

  Future<bool> saveToken(String token) async {
    return await prefs.setString('auth_token', token);
  }

  String? getToken() {
    return prefs.getString('auth_token');
  }

  Future<bool> clearToken() async {
    return await prefs.remove('auth_token');
  }

  // ===== Unlockables =====

  /// Save unlocked themes
  Future<bool> unlockTheme(String themeId) async {
    final unlockedThemes = getUnlockedThemes();
    if (!unlockedThemes.contains(themeId)) {
      unlockedThemes.add(themeId);
      return await prefs.setStringList('unlocked_themes', unlockedThemes);
    }
    return true;
  }

  List<String> getUnlockedThemes() {
    return prefs.getStringList('unlocked_themes') ?? [];
  }

  /// Save unlocked characters
  Future<bool> unlockCharacter(String characterId) async {
    final unlockedChars = getUnlockedCharacters();
    if (!unlockedChars.contains(characterId)) {
      unlockedChars.add(characterId);
      return await prefs.setStringList('unlocked_characters', unlockedChars);
    }
    return true;
  }

  List<String> getUnlockedCharacters() {
    return prefs.getStringList('unlocked_characters') ?? [];
  }

  /// Save current theme
  Future<bool> setCurrentTheme(String themeId) async {
    return await prefs.setString('current_theme', themeId);
  }

  String? getCurrentTheme() {
    return prefs.getString('current_theme');
  }

  // ===== Ad Removal =====

  Future<bool> setAdFreeUntil(DateTime dateTime) async {
    return await prefs.setString('ad_free_until', dateTime.toIso8601String());
  }

  DateTime? getAdFreeUntil() {
    final dateStr = prefs.getString('ad_free_until');
    if (dateStr == null) return null;
    return DateTime.tryParse(dateStr);
  }

  bool isAdFree() {
    final adFreeUntil = getAdFreeUntil();
    if (adFreeUntil == null) return false;
    return DateTime.now().isBefore(adFreeUntil);
  }

  // ===== Hints =====

  int getAvailableHints() {
    return prefs.getInt('available_hints') ?? 0;
  }

  Future<bool> addHints(int count) async {
    final currentHints = getAvailableHints();
    return await prefs.setInt('available_hints', currentHints + count);
  }

  Future<bool> useHint() async {
    final currentHints = getAvailableHints();
    if (currentHints <= 0) return false;
    return await prefs.setInt('available_hints', currentHints - 1);
  }

  // ===== Clear all data =====

  Future<bool> clearAll() async {
    return await prefs.clear();
  }
}
