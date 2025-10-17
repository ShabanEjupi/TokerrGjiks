import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter/foundation.dart';
import '../config/api_keys.dart';

/// Sentry Service for Error Tracking and Performance Monitoring
/// Automatically captures errors, crashes, and performance data
class SentryService {
  static bool _isInitialized = false;

  /// Initialize Sentry
  static Future<void> initialize() async {
    if (_isInitialized) return;

    if (ApiKeys.sentryDsn.isEmpty || ApiKeys.sentryDsn.contains('XXXX')) {
      print('SentryService: DSN not configured, skipping initialization');
      return;
    }

    try {
      await SentryFlutter.init(
        (options) {
          options.dsn = ApiKeys.sentryDsn;
          
          // Set environment
          options.environment = kDebugMode ? 'development' : 'production';
          
          // Set release version
          options.release = 'tokerrgjik@1.0.0'; // Update with your app version
          
          // Performance monitoring
          options.tracesSampleRate = 1.0; // 100% in development, reduce in production
          
          // Enable automatic breadcrumbs
          options.enableAutoSessionTracking = true;
          // Note: sessionTrackingIntervalMillis is deprecated in newer versions
          
          // Attach screenshots on errors
          options.attachScreenshot = true;
          
          // Before send callback - filter sensitive data
          options.beforeSend = (event, {hint}) {
            // Don't send events in development if you prefer
            if (kDebugMode) {
              print('Sentry event: ${event.message ?? event.exceptions?.first.type}');
              // return null; // Uncomment to disable in debug mode
            }
            
            // Filter out sensitive data
            if (event.user != null) {
              event = event.copyWith(
                user: event.user?.copyWith(
                  email: null, // Remove email for privacy
                ),
              );
            }
            
            return event;
          };
          
          // Before breadcrumb callback
          options.beforeBreadcrumb = (breadcrumb, {hint}) {
            // Filter out sensitive breadcrumbs
            if (breadcrumb?.message?.contains('password') ?? false) {
              return null; // Don't send breadcrumbs with passwords
            }
            return breadcrumb;
          };
        },
      );

      _isInitialized = true;
      print('SentryService: Initialized successfully');
    } catch (e) {
      print('SentryService initialization error: $e');
    }
  }

  /// Check if Sentry is initialized
  static bool get isInitialized => _isInitialized;

  // ==================== ERROR REPORTING ====================

  /// Capture an exception
  static Future<void> captureException(
    dynamic exception,
    dynamic stackTrace, {
    String? message,
    Map<String, dynamic>? extra,
    SentryLevel? level,
  }) async {
    if (!_isInitialized) return;

    try {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
        hint: Hint.withMap({
          'message': message,
          if (extra != null) ...extra,
        }),
        withScope: (scope) {
          if (level != null) scope.level = level;
          if (extra != null) {
            extra.forEach((key, value) {
              scope.setExtra(key, value);
            });
          }
        },
      );
    } catch (e) {
      print('Failed to capture exception in Sentry: $e');
    }
  }

  /// Capture a message
  static Future<void> captureMessage(
    String message, {
    SentryLevel level = SentryLevel.info,
    Map<String, dynamic>? extra,
  }) async {
    if (!_isInitialized) return;

    try {
      await Sentry.captureMessage(
        message,
        level: level,
        withScope: (scope) {
          if (extra != null) {
            extra.forEach((key, value) {
              scope.setExtra(key, value);
            });
          }
        },
      );
    } catch (e) {
      print('Failed to capture message in Sentry: $e');
    }
  }

  // ==================== USER CONTEXT ====================

  /// Set user context
  static void setUser({
    required String id,
    String? username,
    String? email,
    Map<String, dynamic>? extra,
  }) {
    if (!_isInitialized) return;

    Sentry.configureScope((scope) {
      scope.setUser(SentryUser(
        id: id,
        username: username,
        email: email, // Be careful with PII
        data: extra,
      ));
    });
  }

  /// Clear user context (on logout)
  static void clearUser() {
    if (!_isInitialized) return;
    
    Sentry.configureScope((scope) {
      scope.setUser(null);
    });
  }

  // ==================== BREADCRUMBS ====================

  /// Add a breadcrumb (for debugging)
  static void addBreadcrumb({
    required String message,
    String? category,
    SentryLevel level = SentryLevel.info,
    Map<String, dynamic>? data,
  }) {
    if (!_isInitialized) return;

    Sentry.addBreadcrumb(Breadcrumb(
      message: message,
      category: category,
      level: level,
      data: data,
      timestamp: DateTime.now(),
    ));
  }

  // ==================== CUSTOM CONTEXTS ====================

  /// Set custom context
  static void setContext(String key, Map<String, dynamic> context) {
    if (!_isInitialized) return;

    Sentry.configureScope((scope) {
      scope.setContexts(key, context);
    });
  }

  /// Set game context
  static void setGameContext({
    required String gameMode,
    String? roomId,
    int? playerCount,
    String? gamePhase,
  }) {
    setContext('game', {
      'mode': gameMode,
      if (roomId != null) 'room_id': roomId,
      if (playerCount != null) 'player_count': playerCount,
      if (gamePhase != null) 'phase': gamePhase,
    });
  }

  // ==================== PERFORMANCE MONITORING ====================

  /// Start a transaction (for performance monitoring)
  static ISentrySpan? startTransaction({
    required String name,
    required String operation,
    Map<String, dynamic>? data,
  }) {
    if (!_isInitialized) return null;

    final transaction = Sentry.startTransaction(
      name,
      operation,
      bindToScope: true,
    );

    if (data != null) {
      data.forEach((key, value) {
        transaction.setData(key, value);
      });
    }

    return transaction;
  }

  /// Measure operation performance
  static Future<T> measurePerformance<T>({
    required String name,
    required String operation,
    required Future<T> Function() function,
    Map<String, dynamic>? data,
  }) async {
    if (!_isInitialized) {
      return await function();
    }

    final transaction = startTransaction(
      name: name,
      operation: operation,
      data: data,
    );

    try {
      final result = await function();
      transaction?.status = const SpanStatus.ok();
      return result;
    } catch (e) {
      transaction?.status = const SpanStatus.internalError();
      transaction?.throwable = e;
      rethrow;
    } finally {
      await transaction?.finish();
    }
  }

  // ==================== TAGS ====================

  /// Set tag
  static void setTag(String key, String value) {
    if (!_isInitialized) return;

    Sentry.configureScope((scope) {
      scope.setTag(key, value);
    });
  }

  /// Set multiple tags
  static void setTags(Map<String, String> tags) {
    if (!_isInitialized) return;

    Sentry.configureScope((scope) {
      tags.forEach((key, value) {
        scope.setTag(key, value);
      });
    });
  }

  // ==================== NETWORK TRACKING ====================

  /// Track API call
  static Future<T> trackApiCall<T>({
    required String url,
    required String method,
    required Future<T> Function() function,
  }) async {
    final span = Sentry.getSpan()?.startChild(
      'http.client',
      description: '$method $url',
    );

    span?.setData('url', url);
    span?.setData('method', method);

    try {
      final result = await function();
      span?.status = const SpanStatus.ok();
      return result;
    } catch (e) {
      span?.status = const SpanStatus.internalError();
      span?.throwable = e;
      
      // Also capture as exception
      await captureException(
        e,
        StackTrace.current,
        message: 'API call failed: $method $url',
        extra: {'url': url, 'method': method},
      );
      
      rethrow;
    } finally {
      await span?.finish();
    }
  }

  // ==================== GAME EVENTS ====================

  /// Track game started
  static void trackGameStarted({
    required String gameMode,
    int? playerCount,
  }) {
    addBreadcrumb(
      message: 'Game started',
      category: 'game',
      level: SentryLevel.info,
      data: {
        'mode': gameMode,
        if (playerCount != null) 'player_count': playerCount,
      },
    );
  }

  /// Track game ended
  static void trackGameEnded({
    required String gameMode,
    required String result,
    int? duration,
  }) {
    addBreadcrumb(
      message: 'Game ended',
      category: 'game',
      level: SentryLevel.info,
      data: {
        'mode': gameMode,
        'result': result,
        if (duration != null) 'duration': duration,
      },
    );
  }

  /// Track multiplayer connection
  static void trackMultiplayerConnection({
    required bool connected,
    String? error,
  }) {
    addBreadcrumb(
      message: connected ? 'Multiplayer connected' : 'Multiplayer disconnected',
      category: 'multiplayer',
      level: connected ? SentryLevel.info : SentryLevel.warning,
      data: {
        'connected': connected,
        if (error != null) 'error': error,
      },
    );
  }

  // ==================== CLOSE ====================

  /// Close Sentry (call on app dispose)
  static Future<void> close() async {
    if (!_isInitialized) return;

    try {
      await Sentry.close();
      _isInitialized = false;
      print('SentryService: Closed');
    } catch (e) {
      print('Failed to close Sentry: $e');
    }
  }
}
