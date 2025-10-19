import 'package:flutter/material.dart';

/// Unified theme system for TokerrGjiks
/// Single source of truth for all theme-related constants
class AppThemes {
  // Theme definitions with consistent naming (removed pink and amethyst)
  static const Map<String, GameTheme> themes = {
    'classic': GameTheme(
      name: '✨ Klasike (Ari)',
      nameShort: 'Klasike',
      boardColor: Color(0xFFDAA520), // Gold
      player1Color: Color(0xFFFFF8DC), // Cream - visible on all boards
      player2Color: Colors.black87,
      description: 'Tabelë e artë 3D me ngjyra klasike',
    ),
    'dark': GameTheme(
      name: '🌙 E errët',
      nameShort: 'E errët',
      boardColor: Color(0xFF424242), // Dark grey
      player1Color: Color(0xFFFFF8DC), // Cream
      player2Color: Color(0xFFFFD700), // Bright gold
      description: 'Tabelë e errët me figura të ndritshme',
    ),
    'nature': GameTheme(
      name: '🌲 Natyrore',
      nameShort: 'Natyrore',
      boardColor: Color(0xFF8B4513), // Saddle brown
      player1Color: Color(0xFFFFF8DC), // Cream
      player2Color: Color(0xFF228B22), // Forest green
      description: 'Ngjyra druri natyror',
    ),
    'ocean': GameTheme(
      name: '🌊 Oqean',
      nameShort: 'Oqean',
      boardColor: Color(0xFF1E90FF), // Dodger blue
      player1Color: Color(0xFFFFF8DC), // Cream
      player2Color: Color(0xFF006994), // Darker blue
      description: 'Temë blu oqeani',
    ),
    'custom': GameTheme(
      name: '🎨 E personalizuar',
      nameShort: 'Custom',
      boardColor: Color(0xFFDAA520), // Default to gold
      player1Color: Color(0xFFFFF8DC), // Default to cream
      player2Color: Colors.black87, // Default to black
      description: 'Krijuar nga ti - zgjedh ngjyrat',
    ),
  };

  /// Get theme data by key
  static GameTheme getTheme(String key) {
    return themes[key] ?? themes['classic']!;
  }

  /// Get all theme keys
  static List<String> get themeKeys => themes.keys.toList();

  /// Get short name for display in settings
  static String getShortName(String key) {
    return themes[key]?.nameShort ?? key;
  }

  /// Get full name with emoji for display in game
  static String getFullName(String key) {
    return themes[key]?.name ?? key;
  }

  /// Get description
  static String getDescription(String key) {
    return themes[key]?.description ?? '';
  }
}

/// Game theme data class (renamed to avoid conflict with Flutter's ThemeData)
class GameTheme {
  final String name;
  final String nameShort;
  final Color boardColor;
  final Color player1Color;
  final Color player2Color;
  final String description;

  const GameTheme({
    required this.name,
    required this.nameShort,
    required this.boardColor,
    required this.player1Color,
    required this.player2Color,
    required this.description,
  });
}

