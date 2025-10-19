import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../config/api_keys.dart';
import 'auth_service.dart';

/// Enhanced Database Service with SQLite
/// Provides robust local storage that persists even after app reinstall
/// Includes backup/restore functionality
class DatabaseService {
  static Database? _database;
  static const String _databaseName = 'tokerrgjik.db';
  static const int _databaseVersion = 1;

  // Table names
  static const String _tableUsers = 'users';
  static const String _tableGameHistory = 'game_history';
  static const String _tableAchievements = 'achievements';
  static const String _tableSettings = 'settings';

  /// Initialize the database
  static Future<void> initialize() async {
    if (kIsWeb) {
      // Skip SQLite initialization on web
      print('DatabaseService: Web mode - using remote database');
      return;
    }
    
    if (_database != null) return;

    try {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final path = join(documentsDirectory.path, _databaseName);

      _database = await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );

      print('DatabaseService: Initialized at $path');
    } catch (e) {
      print('DatabaseService initialization error: $e');
      rethrow;
    }
  }

  /// Create database tables
  static Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE $_tableUsers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT UNIQUE NOT NULL,
        username TEXT NOT NULL,
        email TEXT,
        avatar TEXT,
        coins INTEGER DEFAULT 0,
        level INTEGER DEFAULT 1,
        xp INTEGER DEFAULT 0,
        games_played INTEGER DEFAULT 0,
        games_won INTEGER DEFAULT 0,
        games_lost INTEGER DEFAULT 0,
        win_streak INTEGER DEFAULT 0,
        best_win_streak INTEGER DEFAULT 0,
        total_play_time INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        synced_at TEXT
      )
    ''');

    // Game history table
    await db.execute('''
      CREATE TABLE $_tableGameHistory (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        game_mode TEXT NOT NULL,
        opponent_name TEXT,
        result TEXT NOT NULL,
        score INTEGER DEFAULT 0,
        duration INTEGER DEFAULT 0,
        moves_count INTEGER DEFAULT 0,
        played_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES $_tableUsers (user_id)
      )
    ''');

    // Achievements table
    await db.execute('''
      CREATE TABLE $_tableAchievements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        achievement_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        icon TEXT,
        unlocked_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        UNIQUE(user_id, achievement_id),
        FOREIGN KEY (user_id) REFERENCES $_tableUsers (user_id)
      )
    ''');

    // Settings table
    await db.execute('''
      CREATE TABLE $_tableSettings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    print('DatabaseService: Tables created');
  }

  /// Handle database upgrades
  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle future schema migrations
    print('DatabaseService: Upgrading from $oldVersion to $newVersion');
  }

  /// Get database instance
  static Database get database {
    if (_database == null) {
      throw Exception('DatabaseService not initialized. Call initialize() first.');
    }
    return _database!;
  }

  // ==================== USER OPERATIONS ====================

  /// Save or update user profile
  static Future<int> saveUser(Map<String, dynamic> userData) async {
    final now = DateTime.now().toIso8601String();
    userData['updated_at'] = now;

    if (!userData.containsKey('created_at')) {
      userData['created_at'] = now;
    }

    try {
      // Check if user exists
      final existing = await getUser(userData['user_id']);
      
      if (existing != null) {
        // Update existing user
        await database.update(
          _tableUsers,
          userData,
          where: 'user_id = ?',
          whereArgs: [userData['user_id']],
        );
        return existing['id'] as int;
      } else {
        // Insert new user
        return await database.insert(
          _tableUsers,
          userData,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    } catch (e) {
      print('Error saving user: $e');
      rethrow;
    }
  }

  /// Get user by user_id
  static Future<Map<String, dynamic>?> getUser(String userId) async {
    try {
      final results = await database.query(
        _tableUsers,
        where: 'user_id = ?',
        whereArgs: [userId],
        limit: 1,
      );

      return results.isNotEmpty ? results.first : null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  /// Get current user (assumes single user per device)
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final results = await database.query(
        _tableUsers,
        orderBy: 'updated_at DESC',
        limit: 1,
      );

      return results.isNotEmpty ? results.first : null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  /// Update user stats
  static Future<void> updateUserStats({
    required String userId,
    int? coins,
    int? gamesPlayed,
    int? gamesWon,
    int? gamesLost,
    int? winStreak,
    int? bestWinStreak,
    int? level,
    int? xp,
    int? totalPlayTime,
  }) async {
    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (coins != null) updates['coins'] = coins;
    if (gamesPlayed != null) updates['games_played'] = gamesPlayed;
    if (gamesWon != null) updates['games_won'] = gamesWon;
    if (gamesLost != null) updates['games_lost'] = gamesLost;
    if (winStreak != null) updates['win_streak'] = winStreak;
    if (bestWinStreak != null) updates['best_win_streak'] = bestWinStreak;
    if (level != null) updates['level'] = level;
    if (xp != null) updates['xp'] = xp;
    if (totalPlayTime != null) updates['total_play_time'] = totalPlayTime;

    await database.update(
      _tableUsers,
      updates,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // ==================== GAME HISTORY OPERATIONS ====================

  /// Save game history
  static Future<int> saveGameHistory(Map<String, dynamic> gameData) async {
    gameData['played_at'] = gameData['played_at'] ?? DateTime.now().toIso8601String();
    gameData['synced'] = 0;

    return await database.insert(
      _tableGameHistory,
      gameData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get game history for a user
  static Future<List<Map<String, dynamic>>> getGameHistory(
    String userId, {
    int limit = 50,
    int offset = 0,
  }) async {
    return await database.query(
      _tableGameHistory,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'played_at DESC',
      limit: limit,
      offset: offset,
    );
  }

  /// Get unsynced game history
  static Future<List<Map<String, dynamic>>> getUnsyncedGameHistory() async {
    return await database.query(
      _tableGameHistory,
      where: 'synced = ?',
      whereArgs: [0],
    );
  }

  /// Mark game history as synced
  static Future<void> markGameHistorySynced(int id) async {
    await database.update(
      _tableGameHistory,
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== ACHIEVEMENTS OPERATIONS ====================

  /// Unlock achievement
  static Future<int> unlockAchievement({
    required String userId,
    required String achievementId,
    required String title,
    String? description,
    String? icon,
  }) async {
    final data = {
      'user_id': userId,
      'achievement_id': achievementId,
      'title': title,
      'description': description,
      'icon': icon,
      'unlocked_at': DateTime.now().toIso8601String(),
      'synced': 0,
    };

    return await database.insert(
      _tableAchievements,
      data,
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// Get user achievements
  static Future<List<Map<String, dynamic>>> getUserAchievements(String userId) async {
    return await database.query(
      _tableAchievements,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'unlocked_at DESC',
    );
  }

  /// Check if achievement is unlocked
  static Future<bool> isAchievementUnlocked(String userId, String achievementId) async {
    final results = await database.query(
      _tableAchievements,
      where: 'user_id = ? AND achievement_id = ?',
      whereArgs: [userId, achievementId],
      limit: 1,
    );

    return results.isNotEmpty;
  }

  // ==================== SETTINGS OPERATIONS ====================

  /// Save setting
  static Future<void> saveSetting(String key, dynamic value) async {
    final data = {
      'key': key,
      'value': jsonEncode(value),
      'updated_at': DateTime.now().toIso8601String(),
    };

    await database.insert(
      _tableSettings,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get setting
  static Future<dynamic> getSetting(String key, {dynamic defaultValue}) async {
    final results = await database.query(
      _tableSettings,
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );

    if (results.isNotEmpty) {
      try {
        return jsonDecode(results.first['value'] as String);
      } catch (e) {
        print('Error decoding setting $key: $e');
      }
    }

    return defaultValue;
  }

  /// Get all settings
  static Future<Map<String, dynamic>> getAllSettings() async {
    final results = await database.query(_tableSettings);
    final settings = <String, dynamic>{};

    for (final row in results) {
      try {
        settings[row['key'] as String] = jsonDecode(row['value'] as String);
      } catch (e) {
        print('Error decoding setting: $e');
      }
    }

    return settings;
  }

  // ==================== BACKUP & RESTORE ====================

  /// Create a backup of the database
  static Future<String> createBackup() async {
    try {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final dbPath = join(documentsDirectory.path, _databaseName);
      final dbFile = File(dbPath);
      
      if (!await dbFile.exists()) {
        throw Exception('Database file not found');
      }

      final backupDir = await getApplicationDocumentsDirectory();
      final backupPath = join(
        backupDir.path,
        'tokerrgjik_backup_${DateTime.now().millisecondsSinceEpoch}.db',
      );

      await dbFile.copy(backupPath);
      print('Backup created: $backupPath');
      
      return backupPath;
    } catch (e) {
      print('Error creating backup: $e');
      rethrow;
    }
  }

  /// Restore database from backup
  static Future<void> restoreFromBackup(String backupPath) async {
    try {
      final backupFile = File(backupPath);
      
      if (!await backupFile.exists()) {
        throw Exception('Backup file not found');
      }

      // Close current database
      await _database?.close();
      _database = null;

      // Replace database with backup
      final dbPath = join(
        (await getApplicationDocumentsDirectory()).path,
        _databaseName,
      );
      
      await backupFile.copy(dbPath);
      print('Database restored from: $backupPath');

      // Reinitialize database
      await initialize();
    } catch (e) {
      print('Error restoring backup: $e');
      rethrow;
    }
  }

  /// Export user data as JSON (for cloud sync or transfer)
  static Future<Map<String, dynamic>> exportUserData(String userId) async {
    final user = await getUser(userId);
    final gameHistory = await getGameHistory(userId, limit: 1000);
    final achievements = await getUserAchievements(userId);

    return {
      'user': user,
      'game_history': gameHistory,
      'achievements': achievements,
      'exported_at': DateTime.now().toIso8601String(),
    };
  }

  /// Import user data from JSON
  static Future<void> importUserData(Map<String, dynamic> data) async {
    try {
      // Import user
      if (data['user'] != null) {
        await saveUser(data['user']);
      }

      // Import game history
      if (data['game_history'] != null) {
        for (final game in data['game_history']) {
          await saveGameHistory(game);
        }
      }

      // Import achievements
      if (data['achievements'] != null) {
        for (final achievement in data['achievements']) {
          await database.insert(
            _tableAchievements,
            achievement,
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
      }

      print('User data imported successfully');
    } catch (e) {
      print('Error importing user data: $e');
      rethrow;
    }
  }

  // ==================== UTILITY METHODS ====================

  /// Clear all data
  static Future<void> clearAllData() async {
    await database.delete(_tableUsers);
    await database.delete(_tableGameHistory);
    await database.delete(_tableAchievements);
    await database.delete(_tableSettings);
    print('All data cleared');
  }

  /// Get database statistics
  static Future<Map<String, int>> getDatabaseStats() async {
    final userCount = Sqflite.firstIntValue(
      await database.rawQuery('SELECT COUNT(*) FROM $_tableUsers'),
    );
    final gameCount = Sqflite.firstIntValue(
      await database.rawQuery('SELECT COUNT(*) FROM $_tableGameHistory'),
    );
    final achievementCount = Sqflite.firstIntValue(
      await database.rawQuery('SELECT COUNT(*) FROM $_tableAchievements'),
    );

    return {
      'users': userCount ?? 0,
      'games': gameCount ?? 0,
      'achievements': achievementCount ?? 0,
    };
  }

  /// Close database connection
  static Future<void> close() async {
    await _database?.close();
    _database = null;
    print('DatabaseService: Closed');
  }
  
  // ==================== WEB API METHODS ====================
  
  /// Fetch user data from web API
  static Future<Map<String, dynamic>?> fetchUserFromWeb(String userId) async {
    if (!kIsWeb) return null;
    
    try {
      final response = await http.get(
        Uri.parse('${ApiKeys.currentServerUrl}/api/users/$userId'),
        headers: {
          if (AuthService.authToken != null)
            'Authorization': 'Bearer ${AuthService.authToken}',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error fetching user from web: $e');
    }
    return null;
  }
  
  /// Save user data to web API
  static Future<bool> saveUserToWeb(Map<String, dynamic> userData) async {
    if (!kIsWeb) return false;
    
    try {
      final response = await http.post(
        Uri.parse('${ApiKeys.currentServerUrl}/api/users'),
        headers: {
          'Content-Type': 'application/json',
          if (AuthService.authToken != null)
            'Authorization': 'Bearer ${AuthService.authToken}',
        },
        body: json.encode(userData),
      ).timeout(const Duration(seconds: 10));
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error saving user to web: $e');
      return false;
    }
  }
  
  /// Fetch leaderboard from web API
  static Future<List<Map<String, dynamic>>> fetchLeaderboardFromWeb({int limit = 100}) async {
    if (!kIsWeb) return [];
    
    try {
      final response = await http.get(
        Uri.parse('${ApiKeys.currentServerUrl}/api/leaderboard?limit=$limit'),
        headers: {
          if (AuthService.authToken != null)
            'Authorization': 'Bearer ${AuthService.authToken}',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print('Error fetching leaderboard from web: $e');
    }
    return [];
  }
  
  /// Save game result to web API
  static Future<bool> saveGameToWeb(Map<String, dynamic> gameData) async {
    if (!kIsWeb) return false;
    
    try {
      final response = await http.post(
        Uri.parse('${ApiKeys.currentServerUrl}/api/games'),
        headers: {
          'Content-Type': 'application/json',
          if (AuthService.authToken != null)
            'Authorization': 'Bearer ${AuthService.authToken}',
        },
        body: json.encode(gameData),
      ).timeout(const Duration(seconds: 10));
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error saving game to web: $e');
      return false;
    }
  }
}

