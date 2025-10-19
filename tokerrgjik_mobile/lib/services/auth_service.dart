import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

/// Authentication service for user login/register
/// - Web: Uses backend API with JWT tokens
/// - Mobile: Uses local storage (offline mode)
class AuthService {
  static const String _baseUrl = ApiKeys.currentServerUrl;
  static String? _currentUserId;
  static String? _authToken;
  static String? _currentUsername;
  
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
    
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
          'email': email,
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        _currentUserId = data['userId']?.toString();
        _authToken = data['token'];
        _currentUsername = username;
        await _saveAuthLocal();
        return {
          ...data,
          'success': true,
        };
      } else {
        print('Register failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Register error: $e');
      // Fallback to local mode on error
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
      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _currentUserId = data['userId']?.toString();
        _authToken = data['token'];
        _currentUsername = username;
        await _saveAuthLocal();
        return {
          ...data,
          'success': true,
        };
      } else {
        print('Login failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Login error: $e');
      // Fallback to local mode on error
      return await _createLocalUser(username);
    }
    return null;
  }
  
  /// Guest login (no account needed)
  static Future<Map<String, dynamic>> loginAsGuest() async {
    final guestId = 'guest_${Random().nextInt(999999)}';
    final guestName = 'Guest_${Random().nextInt(9999)}';
    
    _currentUserId = guestId;
    _currentUsername = guestName;
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
        await http.post(
          Uri.parse('$_baseUrl/api/auth/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_authToken',
          },
        ).timeout(const Duration(seconds: 5));
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
