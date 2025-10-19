import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

/// Service for handling local notifications
/// Notifies players when it's their turn to play
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  
  static bool _initialized = false;

  /// Initialize notification service
  static Future<void> initialize() async {
    // Don't initialize on web - not supported
    if (kIsWeb) {
      print('📱 Notifications not supported on web');
      return;
    }

    if (_initialized) return;

    try {
      // Android initialization settings
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Combined initialization settings
      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initialize the plugin
      await _notifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          print('📱 Notification tapped: ${response.payload}');
        },
      );

      // Request permissions on iOS
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await _notifications
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
      }

      // Request permissions on Android 13+ (API level 33+)
      if (defaultTargetPlatform == TargetPlatform.android) {
        await _notifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
      }

      _initialized = true;
      print('📱 Notification service initialized');
    } catch (e) {
      print('⚠️ Error initializing notifications: $e');
    }
  }

  /// Show notification when it's player's turn
  static Future<void> notifyPlayerTurn(int player, {bool isAI = false}) async {
    if (kIsWeb || !_initialized) return;

    try {
      String title;
      String body;

      if (isAI) {
        // AI finished its turn, now it's player's turn
        title = '🎮 Tokerrgjik - Radha jote!';
        body = 'AI luajti - tani është radha jote!';
      } else if (player == 1) {
        title = '🎮 Tokerrgjik - Radha e Lojtarit 1';
        body = 'Është radha jote të luash!';
      } else {
        title = '🎮 Tokerrgjik - Radha e Lojtarit 2';
        body = 'Është radha e Lojtarit 2!';
      }

      // Android notification details
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'tokerrgjik_turns', // channel id
        'Radhët e Lojës', // channel name
        channelDescription: 'Njoftime për radhët në lojë',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
      );

      // iOS notification details
      const DarwinNotificationDetails iosDetails =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
      );

      // Combined notification details
      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Show notification
      await _notifications.show(
        player, // notification id (unique per player)
        title,
        body,
        notificationDetails,
        payload: 'player_$player',
      );

      print('📱 Notification sent: $title');
    } catch (e) {
      print('⚠️ Error showing notification: $e');
    }
  }

  /// Notify when AI is thinking
  static Future<void> notifyAIThinking() async {
    if (kIsWeb || !_initialized) return;

    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'tokerrgjik_ai',
        'AI Lëvizjet',
        channelDescription: 'Njoftime për lëvizjet e AI',
        importance: Importance.low,
        priority: Priority.low,
        ongoing: true, // persistent notification
        icon: '@mipmap/ic_launcher',
      );

      const DarwinNotificationDetails iosDetails =
          DarwinNotificationDetails(
        presentAlert: false, // Don't show alert for AI thinking
        presentBadge: false,
        presentSound: false,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        999, // special id for AI thinking
        '🤖 AI po mendon...',
        'Prit pak derisa AI të luajë',
        notificationDetails,
        payload: 'ai_thinking',
      );
    } catch (e) {
      print('⚠️ Error showing AI notification: $e');
    }
  }

  /// Cancel AI thinking notification
  static Future<void> cancelAIThinking() async {
    if (kIsWeb || !_initialized) return;
    
    try {
      await _notifications.cancel(999);
    } catch (e) {
      print('⚠️ Error canceling notification: $e');
    }
  }

  /// Notify on game end
  static Future<void> notifyGameEnd(String message) async {
    if (kIsWeb || !_initialized) return;

    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'tokerrgjik_game',
        'Loja Përfundoi',
        channelDescription: 'Njoftime kur loja përfundon',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
      );

      const DarwinNotificationDetails iosDetails =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        1000, // game end notification id
        '🏆 Loja Përfundoi!',
        message,
        notificationDetails,
        payload: 'game_end',
      );
    } catch (e) {
      print('⚠️ Error showing game end notification: $e');
    }
  }

  /// Cancel all notifications
  static Future<void> cancelAll() async {
    if (kIsWeb || !_initialized) return;
    
    try {
      await _notifications.cancelAll();
    } catch (e) {
      print('⚠️ Error canceling all notifications: $e');
    }
  }
}
