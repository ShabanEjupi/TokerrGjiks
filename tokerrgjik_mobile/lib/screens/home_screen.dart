import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../models/user_profile.dart';
import '../services/sound_service.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ConfettiController _confettiController;
  bool _showLoginReward = false;
  int _loginBonus = 0;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _checkDailyLogin();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _checkDailyLogin() async {
    final profile = Provider.of<UserProfile>(context, listen: false);
    final now = DateTime.now();
    
    if (profile.lastLoginDate == null || 
        !_isSameDay(profile.lastLoginDate!, now)) {
      await Future.delayed(const Duration(seconds: 1));
      
      // Determine bonus
      if (profile.consecutiveLogins >= 7) {
        _loginBonus = 10;
      } else if (profile.consecutiveLogins >= 3) {
        _loginBonus = 5;
      } else {
        _loginBonus = 2;
      }
      
      setState(() => _showLoginReward = true);
      _confettiController.play();
      SoundService.playCoin();
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF667eea),
                  Color(0xFF764ba2),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildTopBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          _buildTitle(),
                          const SizedBox(height: 40),
                          _buildPlayOptions(),
                          const SizedBox(height: 30),
                          _buildSecondaryButtons(),
                          const SizedBox(height: 30),
                          _buildFooter(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.1,
            ),
          ),
          // Login Reward Dialog
          if (_showLoginReward) _buildLoginRewardDialog(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Consumer<UserProfile>(
      builder: (context, profile, child) {
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // User info
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/settings'),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Text(
                        profile.username[0].toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF667eea),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              profile.username,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (profile.isPro)
                              const Padding(
                                padding: EdgeInsets.only(left: 4),
                                child: Icon(Icons.stars, color: Colors.amber, size: 16),
                              ),
                          ],
                        ),
                        Text(
                          '🪙 ${profile.coins} monedha',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Menu buttons
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.people, color: Colors.white),
                    onPressed: () {
                      Navigator.pushNamed(context, '/friends');
                      SoundService.playClick();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.leaderboard, color: Colors.white),
                    onPressed: () {
                      Navigator.pushNamed(context, '/leaderboard');
                      SoundService.playClick();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.shopping_bag, color: Colors.white),
                    onPressed: () {
                      Navigator.pushNamed(context, '/shop');
                      SoundService.playClick();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white),
                    onPressed: () {
                      Navigator.pushNamed(context, '/settings');
                      SoundService.playClick();
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: const [
          Text(
            '🎮',
            style: TextStyle(fontSize: 80),
          ),
          SizedBox(height: 20),
          Text(
            'Tokerrgjik',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 10.0,
                  color: Colors.black26,
                  offset: Offset(3, 3),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Lojë Tradicionale Strategjike',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white70,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayOptions() {
    return Column(
      children: [
        _buildMenuButton(
          icon: Icons.computer,
          label: 'Luaj kundër AI',
          onPressed: () {
            _showDifficultyDialog();
          },
        ),
        const SizedBox(height: 16),
        _buildMenuButton(
          icon: Icons.people,
          label: 'Luaj me Mik (Lokal)',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const GameScreen(mode: 'local'),
              ),
            );
            SoundService.playClick();
          },
        ),
        const SizedBox(height: 16),
        _buildMenuButton(
          icon: Icons.wifi,
          label: 'Luaj Online',
          gradient: const LinearGradient(
            colors: [Colors.orange, Colors.deepOrange],
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const GameScreen(mode: 'online'),
              ),
            );
            SoundService.playClick();
          },
        ),
      ],
    );
  }

  Widget _buildSecondaryButtons() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildSmallButton(
          icon: Icons.menu_book,
          label: 'Rregullat',
          onPressed: () => _showRulesDialog(context),
        ),
        _buildSmallButton(
          icon: Icons.bar_chart,
          label: 'Statistikat',
          onPressed: _showStatsDialog,
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: const [
          Text(
            'Krijuar për',
            style: TextStyle(color: Colors.white60, fontSize: 14),
          ),
          SizedBox(height: 5),
          Text(
            'Universiteti i Prishtinës',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Kompjutimi Cloud - 2025',
            style: TextStyle(color: Colors.white60, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Gradient? gradient,
  }) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: gradient == null ? Colors.white : Colors.transparent,
          foregroundColor: gradient == null ? const Color(0xFF667eea) : Colors.white,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 26),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: () {
        onPressed();
        SoundService.playClick();
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginRewardDialog() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.card_giftcard, size: 80, color: Colors.amber),
                const SizedBox(height: 16),
                const Text(
                  '🎉 Bonus Ditor! 🎉',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Consumer<UserProfile>(
                  builder: (context, profile, child) {
                    return Text(
                      'Ditë consecutive: ${profile.consecutiveLogins}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  '+$_loginBonus 🪙',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF667eea),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() => _showLoginReward = false);
                    SoundService.playClick();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667eea),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                  ),
                  child: const Text(
                    'Faleminderit!',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDifficultyDialog() {
    final profile = Provider.of<UserProfile>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Zgjedh Vështirësinë'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _difficultyOption('E Lehtë', 'easy', '3 🪙', profile),
              _difficultyOption('Mesatare', 'medium', '5 🪙', profile),
              _difficultyOption('E Vështirë', 'hard', '8 🪙', profile),
              _difficultyOption('Ekspert', 'expert', '12 🪙', profile),
            ],
          ),
        );
      },
    );
  }

  Widget _difficultyOption(String name, String value, String reward, UserProfile profile) {
    final isSelected = profile.difficulty == value;
    
    return Card(
      color: isSelected ? const Color(0xFF667eea).withOpacity(0.1) : null,
      child: ListTile(
        leading: Radio<String>(
          value: value,
          groupValue: profile.difficulty,
          onChanged: (val) {},
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: Text(reward, style: const TextStyle(fontSize: 16)),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GameScreen(mode: 'ai', difficulty: value),
            ),
          );
          SoundService.playClick();
        },
      ),
    );
  }

  void _showStatsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer<UserProfile>(
          builder: (context, profile, child) {
            return AlertDialog(
              title: const Text('📊 Statistikat e mia'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _statRow('Fitore', '${profile.totalWins}', Colors.green),
                    _statRow('Humbje', '${profile.totalLosses}', Colors.red),
                    _statRow('Barazime', '${profile.totalDraws}', Colors.orange),
                    const Divider(),
                    _statRow('Përqindja fitimeve', '${profile.winRate.toStringAsFixed(1)}%', const Color(0xFF667eea)),
                    _statRow('Seria aktuale', '${profile.winStreak}', Colors.amber),
                    _statRow('Seria më e mirë', '${profile.bestStreak}', Colors.amber),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Mbyll'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _statRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showRulesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Si të Luash Tokerrgjik',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF667eea),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildRuleSection(
                  '🎯 Qëllimi',
                  'Formo "rrathë" (3 figura në radhë) për të hequr figurat e kundërshtarit. Fito duke e zvogëluar kundërshtarin në 2 figura ose duke bllokuar lëvizjet e tij.',
                ),
                const SizedBox(height: 15),
                _buildRuleSection(
                  '📝 Fazat e Lojës',
                  '1. Vendosja: Vendos 9 figurat në pika boshe\n'
                      '2. Lëvizja: Lëviz figurat në pika boshe ngjitur\n'
                      '3. Fluturimi: Me 3 figura, mund të "fluturosh" kudo',
                ),
                const SizedBox(height: 15),
                _buildRuleSection(
                  '⭐ Rrathët',
                  'Kur formon një rreth, mund të heqësh një figurë të kundërshtarit (jo ato në rrathë, nëse ka të tjera).',
                ),
                const SizedBox(height: 15),
                _buildRuleSection(
                  '🏆 Fitimi',
                  '• Zvogëlo kundërshtarin në 2 figura\n'
                      '• Bllokoj të gjitha lëvizjet e tij',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Mbyll',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRuleSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF764ba2),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
