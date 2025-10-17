import 'package:flutter/material.dart';
import 'config/api_keys.dart';

class GameConfig {
  // Server - Now using ApiKeys configuration
  static String get serverUrl => ApiKeys.currentServerUrl;
  static String get websocketUrl => ApiKeys.currentWebsocketUrl;

  // Colors
  static const Color primaryColor = Color(0xFF667eea);
  static const Color secondaryColor = Color(0xFF764ba2);
  static const Color accentColor = Color(0xFFFFC107);
  static const Color boardColor = Color(0xFFE0E0E0);
  static const Color player1Color = Color(0xFFFFF8DC); // Cream/Cornsilk - visible on all backgrounds
  static const Color player2Color = Color(0xFFC62828);
  static const Color emptyPositionColor = Colors.white;

  // Game settings
  static const int totalPieces = 9;
  
  // Ad settings
  static const bool enableAds = true;
  static const int gamesBeforeInterstitialAd = 3; // Show ad every 3 games
  static const int coinsForWatchingRewardedAd = 50;
  
  // Multiplayer settings
  static const bool enableLANPlay = true;
  static const bool enablePublicMatching = true;
  static const bool enablePrivateRooms = true;
  
  // Chat settings
  static const bool enableChat = true;
  static const bool enableQuickChat = true;
  static const bool enableEmotes = true;
  static const int maxChatMessageLength = 200;
  
  // Data persistence
  static const bool enableCloudSync = true;
  static const bool autoBackup = true;
  static const int autoBackupIntervalHours = 24;
}
