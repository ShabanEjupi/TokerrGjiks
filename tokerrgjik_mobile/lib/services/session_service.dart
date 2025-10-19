import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../config/api_keys.dart';
import 'auth_service.dart';

/// Session service for multiplayer game rooms
/// - Web: Uses backend API with polling/WebSocket
/// - Mobile: Offline mode (local multiplayer not supported yet)
class SessionService {
  static final String _baseUrl = ApiKeys.currentServerUrl;
  static String? _currentSessionId;
  static StreamController<Map<String, dynamic>>? _gameUpdatesController;
  static Timer? _pollingTimer;
  static int _lastUpdateId = 0;
  
  /// Create a new game session
  static Future<String?> createSession({
    required String gameMode,
    bool isPrivate = false,
    String? inviteCode,
  }) async {
    if (!kIsWeb) {
      // Mobile: Create mock session for testing
      _currentSessionId = 'local_session_${DateTime.now().millisecondsSinceEpoch}';
      print('Created local session: $_currentSessionId');
      return _currentSessionId;
    }
    
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/sessions'),
        headers: {
          'Content-Type': 'application/json',
          if (AuthService.authToken != null)
            'Authorization': 'Bearer ${AuthService.authToken}',
        },
        body: json.encode({
          'userId': AuthService.currentUserId,
          'username': AuthService.currentUsername,
          'gameMode': gameMode,
          'isPrivate': isPrivate,
          'inviteCode': inviteCode,
          'createdAt': DateTime.now().toIso8601String(),
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        _currentSessionId = data['sessionId'];
        _startPolling();
        print('Created session: $_currentSessionId');
        return _currentSessionId;
      } else {
        print('Create session failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Create session error: $e');
    }
    return null;
  }
  
  /// Join an existing session
  static Future<Map<String, dynamic>?> joinSession(String sessionId) async {
    if (!kIsWeb) {
      print('Joined local session: $sessionId');
      _currentSessionId = sessionId;
      return {
        'success': true,
        'sessionId': sessionId,
        'message': 'Joined local session',
      };
    }
    
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/sessions/$sessionId/join'),
        headers: {
          'Content-Type': 'application/json',
          if (AuthService.authToken != null)
            'Authorization': 'Bearer ${AuthService.authToken}',
        },
        body: json.encode({
          'userId': AuthService.currentUserId,
          'username': AuthService.currentUsername,
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _currentSessionId = sessionId;
        _startPolling();
        print('Joined session: $sessionId');
        return {
          'success': true,
          ...data,
        };
      } else {
        print('Join session failed: ${response.statusCode} - ${response.body}');
        return {
          'success': false,
          'error': response.body,
        };
      }
    } catch (e) {
      print('Join session error: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  /// List available sessions
  static Future<List<Map<String, dynamic>>> listSessions({
    String? gameMode,
    bool publicOnly = true,
  }) async {
    if (!kIsWeb) {
      return []; // No sessions in offline mode
    }
    
    try {
      final uri = Uri.parse('$_baseUrl/api/sessions').replace(
        queryParameters: {
          if (gameMode != null) 'gameMode': gameMode,
          if (publicOnly) 'public': 'true',
        },
      );
      
      final response = await http.get(
        uri,
        headers: {
          if (AuthService.authToken != null)
            'Authorization': 'Bearer ${AuthService.authToken}',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        print('List sessions failed: ${response.statusCode}');
      }
    } catch (e) {
      print('List sessions error: $e');
    }
    return [];
  }
  
  /// Send game move to session
  static Future<bool> sendMove(Map<String, dynamic> moveData) async {
    if (_currentSessionId == null) {
      print('No active session');
      return false;
    }
    
    if (!kIsWeb) {
      print('Move sent to local session: $moveData');
      return true; // Mock success for offline
    }
    
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/sessions/$_currentSessionId/move'),
        headers: {
          'Content-Type': 'application/json',
          if (AuthService.authToken != null)
            'Authorization': 'Bearer ${AuthService.authToken}',
        },
        body: json.encode({
          'userId': AuthService.currentUserId,
          'move': moveData,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        print('Move sent successfully');
        return true;
      } else {
        print('Send move failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Send move error: $e');
    }
    return false;
  }
  
  /// Send game state update
  static Future<bool> sendGameState(Map<String, dynamic> gameState) async {
    if (_currentSessionId == null) return false;
    
    if (!kIsWeb) return true; // Mock success
    
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/sessions/$_currentSessionId/state'),
        headers: {
          'Content-Type': 'application/json',
          if (AuthService.authToken != null)
            'Authorization': 'Bearer ${AuthService.authToken}',
        },
        body: json.encode({
          'userId': AuthService.currentUserId,
          'state': gameState,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      ).timeout(const Duration(seconds: 10));
      
      return response.statusCode == 200;
    } catch (e) {
      print('Send game state error: $e');
      return false;
    }
  }
  
  /// Get game updates stream
  static Stream<Map<String, dynamic>> get gameUpdates {
    _gameUpdatesController ??= StreamController<Map<String, dynamic>>.broadcast();
    return _gameUpdatesController!.stream;
  }
  
  /// Start polling for updates (simple implementation for now)
  /// TODO: Upgrade to WebSocket or Server-Sent Events for production
  static void _startPolling() {
    _pollingTimer?.cancel();
    _lastUpdateId = 0;
    
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (_currentSessionId == null || !kIsWeb) {
        timer.cancel();
        return;
      }
      
      try {
        final response = await http.get(
          Uri.parse('$_baseUrl/api/sessions/$_currentSessionId/updates?since=$_lastUpdateId'),
          headers: {
            if (AuthService.authToken != null)
              'Authorization': 'Bearer ${AuthService.authToken}',
          },
        ).timeout(const Duration(seconds: 5));
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          
          if (data is Map<String, dynamic> && data.isNotEmpty) {
            // Update last update ID
            if (data['updateId'] != null) {
              _lastUpdateId = data['updateId'];
            }
            
            // Emit update to stream
            _gameUpdatesController?.add(data);
          } else if (data is List && data.isNotEmpty) {
            // Multiple updates
            for (var update in data) {
              if (update['updateId'] != null) {
                _lastUpdateId = update['updateId'];
              }
              _gameUpdatesController?.add(update);
            }
          }
        }
      } catch (e) {
        print('Polling error: $e');
      }
    });
  }
  
  /// Leave current session
  static Future<void> leaveSession() async {
    if (_currentSessionId != null && kIsWeb) {
      try {
        await http.post(
          Uri.parse('$_baseUrl/api/sessions/$_currentSessionId/leave'),
          headers: {
            'Content-Type': 'application/json',
            if (AuthService.authToken != null)
              'Authorization': 'Bearer ${AuthService.authToken}',
          },
          body: json.encode({
            'userId': AuthService.currentUserId,
          }),
        ).timeout(const Duration(seconds: 5));
      } catch (e) {
        print('Leave session error: $e');
      }
    }
    
    _pollingTimer?.cancel();
    _currentSessionId = null;
    _lastUpdateId = 0;
    print('Left session');
  }
  
  /// Get current session ID
  static String? get currentSessionId => _currentSessionId;
  
  /// Check if in active session
  static bool get isInSession => _currentSessionId != null;
  
  /// Cleanup
  static void dispose() {
    _pollingTimer?.cancel();
    _gameUpdatesController?.close();
    _gameUpdatesController = null;
    _currentSessionId = null;
  }
}
