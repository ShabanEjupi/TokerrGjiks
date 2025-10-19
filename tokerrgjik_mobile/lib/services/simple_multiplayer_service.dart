import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Simplified Multiplayer Service using Polling (No Socket.IO needed!)
/// 
/// Perfect for turn-based games on Netlify.
/// Uses simple HTTP polling every 2 seconds to check for game updates.
/// Much simpler than WebSockets and works great for TokerrGjiks.
class SimpleMultiplayerService {
  static final SimpleMultiplayerService _instance = SimpleMultiplayerService._internal();
  factory SimpleMultiplayerService() => _instance;
  SimpleMultiplayerService._internal();

  static const String baseUrl = 'https://tokerrgjik.netlify.app/.netlify/functions';
  Timer? _pollTimer;
  String? _currentSessionId;

  // Callbacks
  Function(Map<String, dynamic>)? onGameUpdate;
  Function(String)? onOpponentMove;
  Function(String)? onError;

  /// Create a new multiplayer game session
  Future<String?> createSession({
    required String hostUsername,
    String? guestUsername,
    bool isPrivate = false,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/games'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'create_session',
          'host_username': hostUsername,
          'guest_username': guestUsername,
          'is_private': isPrivate,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _currentSessionId = data['session_id'].toString();
        
        // Start polling for updates
        startPolling(_currentSessionId!);
        
        debugPrint('✅ Session created: $_currentSessionId');
        return _currentSessionId;
      } else {
        debugPrint('❌ Failed to create session: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error creating session: $e');
      if (onError != null) onError!('Failed to create game session');
      return null;
    }
  }

  /// Join an existing game session
  Future<bool> joinSession({
    required String sessionId,
    required String username,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/games'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'join_session',
          'session_id': sessionId,
          'username': username,
        }),
      );

      if (response.statusCode == 200) {
        _currentSessionId = sessionId;
        
        // Start polling for updates
        startPolling(sessionId);
        
        debugPrint('✅ Joined session: $sessionId');
        return true;
      } else {
        debugPrint('❌ Failed to join session: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error joining session: $e');
      if (onError != null) onError!('Failed to join game session');
      return false;
    }
  }

  /// Make a move in the current game
  Future<bool> makeMove({
    required String sessionId,
    required int position,
    required String action, // 'place', 'move', 'remove'
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/games'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'make_move',
          'session_id': sessionId,
          'position': position,
          'move_action': action,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Move made: position $position, action $action');
        return true;
      } else {
        debugPrint('❌ Failed to make move: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error making move: $e');
      if (onError != null) onError!('Failed to make move');
      return false;
    }
  }

  /// Start polling for game updates (every 2 seconds)
  void startPolling(String sessionId) {
    stopPolling(); // Stop any existing polling
    
    debugPrint('🔄 Started polling session: $sessionId');
    
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/games?session_id=$sessionId&action=get_state'),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          
          // Notify listeners of game update
          if (onGameUpdate != null) {
            onGameUpdate!(data);
          }
          
          // Check if game is finished
          if (data['status'] == 'completed' || data['status'] == 'cancelled') {
            stopPolling();
            debugPrint('🏁 Game finished, stopped polling');
          }
        }
      } catch (e) {
        debugPrint('Polling error: $e');
        // Don't stop polling on errors, just continue
      }
    });
  }

  /// Stop polling for updates
  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
    debugPrint('⏸️ Stopped polling');
  }

  /// Get list of available game sessions
  Future<List<Map<String, dynamic>>> getAvailableSessions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/games?action=list_sessions'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['sessions'] ?? []);
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('Error getting sessions: $e');
      return [];
    }
  }

  /// Leave current game session
  Future<void> leaveSession() async {
    if (_currentSessionId != null) {
      try {
        await http.post(
          Uri.parse('$baseUrl/games'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'action': 'leave_session',
            'session_id': _currentSessionId,
          }),
        );
      } catch (e) {
        debugPrint('Error leaving session: $e');
      }
      
      stopPolling();
      _currentSessionId = null;
    }
  }

  /// Clean up
  void dispose() {
    stopPolling();
    onGameUpdate = null;
    onOpponentMove = null;
    onError = null;
  }
}
