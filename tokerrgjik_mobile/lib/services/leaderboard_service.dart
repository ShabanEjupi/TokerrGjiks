import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';

class LeaderboardEntry {
  final String username;
  final int wins;
  final int totalGames;
  final double winRate;
  final int winStreak;
  final int rank;
  
  LeaderboardEntry({
    required this.username,
    required this.wins,
    required this.totalGames,
    required this.winRate,
    required this.winStreak,
    required this.rank,
  });
  
  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      username: json['username'],
      wins: json['wins'],
      totalGames: json['totalGames'],
      winRate: json['winRate'].toDouble(),
      winStreak: json['winStreak'],
      rank: json['rank'],
    );
  }
}

class LeaderboardService {
  static Future<List<LeaderboardEntry>> getLeaderboard({int limit = 100}) async {
    try {
      final response = await http.get(
        Uri.parse('${GameConfig.serverUrl}/api/leaderboard?limit=$limit'),
      ).timeout(const Duration(seconds: 3));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((entry) => LeaderboardEntry.fromJson(entry)).toList();
      }
    } catch (e) {
      print('Error fetching leaderboard: $e - Using dummy data');
    }
    
    // Return dummy data if backend is unavailable
    return _getDummyLeaderboard(limit);
  }
  
  static List<LeaderboardEntry> _getDummyLeaderboard(int limit) {
    final names = ['Ardit', 'Bleona', 'Dardan', 'Enis', 'Flaka', 'Gresa', 'Hana', 'Ilir', 'Jeta', 'Kushtrim'];
    return List.generate(limit.clamp(0, 10), (index) {
      return LeaderboardEntry(
        username: names[index],
        wins: 50 - (index * 4),
        totalGames: 60 - (index * 2),
        winRate: (80.0 - (index * 5)).clamp(45, 95),
        winStreak: (10 - index).clamp(0, 10),
        rank: index + 1,
      );
    });
  }
  
  static Future<Map<String, dynamic>?> getUserRank(String username) async {
    try {
      final response = await http.get(
        Uri.parse('${GameConfig.serverUrl}/api/leaderboard/user/$username'),
      ).timeout(const Duration(seconds: 3));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error fetching user rank: $e');
    }
    
    // Return dummy rank if backend unavailable
    return {
      'rank': 15,
      'username': username,
      'wins': 25,
      'total Games': 35,
      'winRate': 71.4,
    };
  }
  
  static Future<void> updatePlayerStats(String username, Map<String, int> stats) async {
    try {
      await http.post(
        Uri.parse('${GameConfig.serverUrl}/api/leaderboard/update'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          ...stats,
        }),
      );
    } catch (e) {
      print('Error updating stats: $e');
    }
  }
}
