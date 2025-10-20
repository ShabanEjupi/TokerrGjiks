import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import '../services/api_service.dart';

/// Authentication service for user login/register
/// - Web: Uses backend API with JWT tokens
/// - Mobile: Uses local storage (offline mode)
class AuthService {
  static final String _baseUrl = ApiKeys.currentServerUrl;
  static String? _currentUserId;
  static String? _authToken;
  static String? _currentUsername;
  
  // Fun random username adjectives and nouns for auto-generated names
  static const List<String> _adjectives = [
    'Swift', 'Clever', 'Mighty', 'Bold', 'Quick', 'Sharp', 'Brave', 'Smart',
    'Wise', 'Calm', 'Epic', 'Super', 'Ultra', 'Mega', 'Alpha', 'Prime',
    'Elite', 'Royal', 'Golden', 'Silver', 'Crystal', 'Shadow', 'Turbo', 'Speedy',
    'Lucky', 'Happy', 'Sunny', 'Bright', 'Cool', 'Rad', 'Epic', 'Legendary',
  ];
  
  static const List<String> _nouns = [
    'Tiger', 'Eagle', 'Dragon', 'Phoenix', 'Wolf', 'Lion', 'Falcon', 'Hawk',
    'Panther', 'Bear', 'Fox', 'Shark', 'Ninja', 'Knight', 'Wizard', 'Warrior',
    'Hunter', 'Champion', 'Master', 'Legend', 'Hero', 'Star', 'Thunder', 'Storm',
    'Racer', 'Gamer', 'Pro', 'Ace', 'King', 'Queen', 'Chief', 'Boss',
  ];
  
  /// Generate a fun random username
  static String generateRandomUsername() {
    final random = Random();
    final adjective = _adjectives[random.nextInt(_adjectives.length)];
    final noun = _nouns[random.nextInt(_nouns.length)];
    final number = random.nextInt(999);
    return '$adjective$noun$number';
  }
  
  /// Register new user
  static Future<Map<String, dynamic>?> register({
    required String username,
    required String password,
    String? email,
  }) async {
    if (!kIsWeb) {
      // Mobile: Create local user
      _currentUserId = 'local_${DateTime.now().millisecondsSinceEpoch}';
      _currentUsername = username;
      await _saveAuthLocal();
      return {
        'userId': _currentUserId,
        'username': username,
        'success': true,
      };
    }
    
    // Web: use ApiService which routes to Netlify functions
    try {
      final result = await ApiService.post('/auth', {
        'action': 'register',
        'username': username,
        'password': password,
        if (email != null) 'email': email,
      });

      if (result != null) {
        // Netlify auth returns user object
        _currentUserId = result['user']?['id']?.toString() ?? result['userId']?.toString();
        _authToken = result['token'] ?? result['token'];
        _currentUsername = username;
        await _saveAuthLocal();
        return { ...result, 'success': true };
      }
    } catch (e) {
      print('Register error: $e');
      return await _createLocalUser(username);
    }
    return null;
  }
  
  /// Login user
  static Future<Map<String, dynamic>?> login({
    required String username,
    required String password,
  }) async {
    if (!kIsWeb) {
      // Mobile: Load local user
      await _loadAuthLocal();
      if (_currentUserId == null) {
        // Create new local user
        return await register(username: username, password: password);
      }
      return {
        'userId': _currentUserId,
        'username': _currentUsername ?? username,
        'success': true,
      };
    }
    
    try {
      final result = await ApiService.post('/auth', {
        'action': 'login',
        'username': username,
        'password': password,
      });

      if (result != null) {
        _currentUserId = result['user']?['id']?.toString() ?? result['userId']?.toString();
        _authToken = result['token'];
        _currentUsername = username;
        await _saveAuthLocal();
        return { ...result, 'success': true };
      }
    } catch (e) {
      print('Login error: $e');
      return await _createLocalUser(username);
    }
    return null;
  }
  
  /// Guest login (no account needed)
  static Future<Map<String, dynamic>> loginAsGuest() async {
    // Check if guest session already exists
    final prefs = await SharedPreferences.getInstance();
    String? existingGuestId = prefs.getString('guest_id');
    String? existingGuestName = prefs.getString('guest_username');
    
    if (existingGuestId != null && existingGuestName != null) {
      // Reuse existing guest session
      _currentUserId = existingGuestId;
      _currentUsername = existingGuestName;
      _isGuest = true;
      
      return {
        'userId': existingGuestId,
        'username': existingGuestName,
        'isGuest': true,
        'success': true,
      };
    }
    
    // Create new guest session
    final guestId = 'guest_${Random().nextInt(999999)}';
    final guestName = generateRandomUsername(); // Use fun random name instead of "Guest_XXXX"
    
    _currentUserId = guestId;
    _currentUsername = guestName;
    _isGuest = true;
    
    // Save guest session
    await prefs.setString('guest_id', guestId);
    await prefs.setString('guest_username', guestName);
    await _saveAuthLocal();
    
    return {
      'userId': guestId,
      'username': guestName,
      'isGuest': true,
      'success': true,
    };
  }
  
  /// Create local user (fallback)
  static Future<Map<String, dynamic>> _createLocalUser(String username) async {
    _currentUserId = 'local_${DateTime.now().millisecondsSinceEpoch}';
    _currentUsername = username;
    await _saveAuthLocal();
    return {
      'userId': _currentUserId,
      'username': username,
      'success': true,
      'offline': true,
    };
  }
  
  /// Logout
  static Future<void> logout() async {
    if (kIsWeb && _authToken != null) {
      try {
        await ApiService.post('/auth', {
          'action': 'logout',
        }, headers: { 'Authorization': 'Bearer $_authToken' });
      } catch (e) {
        print('Logout error: $e');
      }
    }
    
    _currentUserId = null;
    _authToken = null;
    _currentUsername = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('authToken');
    await prefs.remove('username');
  }
  
  /// Get current user ID
  static String? get currentUserId => _currentUserId;
  
  /// Get current username
  static String? get currentUsername => _currentUsername;
  
  /// Set current username (for quick updates)
  static set currentUsername(String? username) {
    _currentUsername = username;
  }
  
  /// Set current username (for profile updates)
  static Future<void> updateUsername(String newUsername) async {
    _currentUsername = newUsername;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', newUsername);
  }
  
  /// Get auth token for API calls
  static String? get authToken => _authToken;
  
  /// Check if logged in
  static bool get isLoggedIn => _currentUserId != null;
  
  /// Check if guest
  static bool get isGuest => _currentUserId?.startsWith('guest_') ?? false;
  
  /// Load auth from local storage
  static Future<void> _loadAuthLocal() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getString('userId');
    _authToken = prefs.getString('authToken');
    _currentUsername = prefs.getString('username');
  }
  
  /// Save auth to local storage
  static Future<void> _saveAuthLocal() async {
    final prefs = await SharedPreferences.getInstance();
    if (_currentUserId != null) {
      await prefs.setString('userId', _currentUserId!);
    }
    if (_authToken != null) {
      await prefs.setString('authToken', _authToken!);
    }
    if (_currentUsername != null) {
      await prefs.setString('username', _currentUsername!);
    }
  }
  
  /// Initialize (load saved auth)
  static Future<void> initialize() async {
    await _loadAuthLocal();
    
    // Auto-login as guest if no user
    if (_currentUserId == null) {
      await loginAsGuest();
    }
  }
  
  /// Verify token is still valid (for web)
  static Future<bool> verifyToken() async {
    if (!kIsWeb || _authToken == null) return true;
    
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/auth/verify'),
        headers: {
          'Authorization': 'Bearer $_authToken',
        },
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      print('Token verification error: $e');
      return false;
    }
  }
}
