import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../services/leaderboard_service.dart';
import '../services/sound_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<LeaderboardEntry> _leaderboard = [];
  Map<String, dynamic>? _userRank;
  bool _loading = true;
  bool _showFullLeaderboard = false;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() => _loading = true);
    
    final profile = Provider.of<UserProfile>(context, listen: false);
    
    final leaderboard = await LeaderboardService.getLeaderboard(limit: 100);
    final userRank = await LeaderboardService.getUserRank(profile.username);
    
    setState(() {
      _leaderboard = leaderboard;
      _userRank = userRank;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🏆 Leaderboard'),
        backgroundColor: const Color(0xFF667eea),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLeaderboard,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadLeaderboard,
              child: Consumer<UserProfile>(
                builder: (context, profile, child) {
                  return Column(
                    children: [
                      _buildUserRankCard(profile),
                      _buildTopThree(),
                      Expanded(
                        child: _buildLeaderboardList(),
                      ),
                    ],
                  );
                },
              ),
            ),
    );
  }

  Widget _buildUserRankCard(UserProfile profile) {
    final userRank = _userRank?['rank'] ?? 0;
    final showInLeaderboard = userRank > 0 && userRank <= 10;

    if (!showInLeaderboard && userRank > 0) {
      // Show user's rank if close to top 10
      return Card(
        margin: const EdgeInsets.all(12),
        color: Colors.amber[50],
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF667eea),
                child: Text(
                  profile.username[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.username,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Pozita: #$userRank',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${profile.totalWins} fitore',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${profile.winRate.toStringAsFixed(1)}% WR',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildTopThree() {
    if (_leaderboard.length < 3) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF667eea).withOpacity(0.1),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_leaderboard.length > 1) _buildPodium(_leaderboard[1], 2, 160),
          _buildPodium(_leaderboard[0], 1, 200),
          if (_leaderboard.length > 2) _buildPodium(_leaderboard[2], 3, 140),
        ],
      ),
    );
  }

  Widget _buildPodium(LeaderboardEntry entry, int position, double height) {
    final colors = [
      Colors.amber,
      Colors.grey[400]!,
      Colors.brown[300]!,
    ];
    final icons = ['🥇', '🥈', '🥉'];

    return Column(
      children: [
        Text(
          icons[position - 1],
          style: const TextStyle(fontSize: 40),
        ),
        const SizedBox(height: 8),
        CircleAvatar(
          radius: position == 1 ? 35 : 28,
          backgroundColor: colors[position - 1],
          child: Text(
            entry.username[0].toUpperCase(),
            style: TextStyle(
              fontSize: position == 1 ? 28 : 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          entry.username,
          style: TextStyle(
            fontSize: position == 1 ? 16 : 14,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '${entry.wins} fitore',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            color: colors[position - 1],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Center(
            child: Text(
              '#$position',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardList() {
    final startIndex = _leaderboard.length > 3 ? 3 : 0;
    final displayList = _showFullLeaderboard
        ? _leaderboard.sublist(startIndex)
        : _leaderboard.sublist(startIndex, (_leaderboard.length - startIndex).clamp(0, 7) + startIndex);

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: displayList.length,
            itemBuilder: (context, index) {
              final entry = displayList[index];
              final actualRank = startIndex + index + 1;
              
              return _buildLeaderboardTile(entry, actualRank);
            },
          ),
        ),
        if (!_showFullLeaderboard && _leaderboard.length > 10)
          TextButton(
            onPressed: () {
              setState(() => _showFullLeaderboard = true);
              SoundService.playClick();
            },
            child: const Text('Shfaq të gjithë →'),
          ),
      ],
    );
  }

  Widget _buildLeaderboardTile(LeaderboardEntry entry, int rank) {
    final isTopTen = rank <= 10;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: isTopTen ? Colors.amber[50] : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isTopTen ? const Color(0xFF667eea) : Colors.grey,
          child: Text(
            '#$rank',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Text(
              entry.username,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (entry.username.endsWith('[PRO]'))
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.stars, color: Colors.amber, size: 16),
              ),
          ],
        ),
        subtitle: Text(
          '${entry.totalGames} lojra • ${entry.winRate.toStringAsFixed(1)}% WR',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${entry.wins}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF667eea),
              ),
            ),
            const Text(
              'fitore',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
