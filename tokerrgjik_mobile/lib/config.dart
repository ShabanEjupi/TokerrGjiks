import 'package:flutter/material.dart';

class GameConfig {
  // Server
  static const String serverUrl = 'http://10.0.2.2:3000'; // Use 10.0.2.2 for Android emulator to connect to localhost

  // Colors
  static const Color primaryColor = Color(0xFF667eea);
  static const Color secondaryColor = Color(0xFF764ba2);
  static const Color accentColor = Color(0xFFFFC107);
  static const Color boardColor = Color(0xFFE0E0E0);
  static const Color player1Color = Color(0xFF0D47A1);
  static const Color player2Color = Color(0xFFC62828);
  static const Color emptyPositionColor = Colors.white;

  // Game settings
  static const int totalPieces = 9;
}
