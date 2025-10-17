import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../services/ad_service.dart';
import '../services/sound_service.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    AdService.loadRewardedAd();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dyqani'),
        backgroundColor: const Color(0xFF667eea),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.diamond), text: 'PRO'),
            Tab(icon: Icon(Icons.monetization_on), text: 'Monedha'),
            Tab(icon: Icon(Icons.video_library), text: 'Reklama'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProTab(),
          _buildCoinsTab(),
          _buildAdsTab(),
        ],
      ),
    );
  }

  Widget _buildProTab() {
    return Consumer<UserProfile>(
      builder: (context, profile, child) {
        if (profile.isPro) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, size: 100, color: Colors.green),
                const SizedBox(height: 20),
                const Text(
                  '✨ Ti je PRO! ✨',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'Faleminderit për mbështetjen!',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildProCard(
              title: 'TOKERRGJIK PRO',
              subtitle: '12 muaj',
              price: '€20.82',
              originalPrice: '€41.64',
              discount: '50% ZBRITJE!',
              features: const [
                '✓ Pa reklama për gjithmonë',
                '✓ Tema ekskluzive',
                '✓ Ikona dhe ngjyra të personalizuara',
                '✓ 1000 monedha bonus',
                '✓ Badge "PRO" në leaderboard',
                '✓ Mbështetje prioritare',
              ],
              onTap: () => _purchasePro(context, profile, 12, 20.82),
            ),
            const SizedBox(height: 16),
            _buildProCard(
              title: 'TOKERRGJIK PRO',
              subtitle: '6 muaj',
              price: '€12.99',
              features: const [
                '✓ Pa reklama për 6 muaj',
                '✓ Tema ekskluzive',
                '✓ 500 monedha bonus',
                '✓ Badge "PRO" në leaderboard',
              ],
              onTap: () => _purchasePro(context, profile, 6, 12.99),
            ),
            const SizedBox(height: 16),
            _buildProCard(
              title: 'TOKERRGJIK PRO',
              subtitle: '1 muaj',
              price: '€2.99',
              features: const [
                '✓ Pa reklama për 1 muaj',
                '✓ Tema ekskluzive',
                '✓ 100 monedha bonus',
              ],
              onTap: () => _purchasePro(context, profile, 1, 2.99),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCoinsTab() {
    return Consumer<UserProfile>(
      builder: (context, profile, child) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildCoinBalance(profile.coins),
            const SizedBox(height: 24),
            _buildCoinPackage(
              context,
              profile,
              coins: 10000,
              price: '€20.82',
              originalPrice: '€41.64',
              discount: '50% ZBRITJE!',
              icon: '💎',
            ),
            const SizedBox(height: 16),
            _buildCoinPackage(
              context,
              profile,
              coins: 5000,
              price: '€12.99',
              icon: '💰',
            ),
            const SizedBox(height: 16),
            _buildCoinPackage(
              context,
              profile,
              coins: 2000,
              price: '€5.99',
              icon: '🪙',
            ),
            const SizedBox(height: 16),
            _buildCoinPackage(
              context,
              profile,
              coins: 500,
              price: '€1.99',
              icon: '🔹',
            ),
            const SizedBox(height: 24),
            _buildInfoCard(
              'Përdor monedhat për:',
              [
                '• Blerje temash dhe ikona',
                '• Unlock karaktere speciale',
                '• Skip reklamave (nëse nuk je PRO)',
                '• Merr hint gjatë lojës',
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildAdsTab() {
    return Consumer<UserProfile>(
      builder: (context, profile, child) {
        if (profile.isPro) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.block, size: 100, color: Colors.orange),
                const SizedBox(height: 20),
                const Text(
                  'Pa Reklama!',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'Ti je PRO - nuk do të shohësh reklama',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(Icons.play_circle_outline, size: 80, color: Color(0xFF667eea)),
                    const SizedBox(height: 16),
                    const Text(
                      'Shiko Reklamë - Merr Monedha!',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Shiko një reklamë të shkurtër dhe merr 3 monedha falas!',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: AdService.isRewardedAdReady
                          ? () => _watchAdForCoins(context, profile)
                          : null,
                      icon: const Icon(Icons.play_arrow, size: 28),
                      label: Text(
                        AdService.isRewardedAdReady
                            ? 'Shiko Reklamë'
                            : 'Duke u ngarkuar...',
                        style: const TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF667eea),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildInfoCard(
              'Përfitime të Reklamave:',
              [
                '• Merr 3 monedha për çdo reklamë',
                '• Reklamat janë 15-30 sekonda',
                '• Pa limit ditor!',
                '• Mbështet zhvilluesit e lojës',
              ],
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.orange[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.orange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Nuk do të shohësh reklama? Përmirëso në PRO!',
                        style: TextStyle(color: Colors.orange[900]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCoinBalance(int coins) {
    return Card(
      color: const Color(0xFFFFF9C4),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.monetization_on, size: 40, color: Colors.amber),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Monedhat e tua',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                Text(
                  '$coins 🪙',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProCard({
    required String title,
    required String subtitle,
    required String price,
    String? originalPrice,
    String? discount,
    required List<String> features,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF667eea),
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  if (discount != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        discount,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              ...features.map((feature) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  feature,
                  style: const TextStyle(fontSize: 15),
                ),
              )),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (originalPrice != null)
                        Text(
                          originalPrice,
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      Text(
                        price,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF667eea),
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667eea),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('Bli Tani', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoinPackage(
    BuildContext context,
    UserProfile profile, {
    required int coins,
    required String price,
    String? originalPrice,
    String? discount,
    required String icon,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _purchaseCoins(context, profile, coins, price),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 50)),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$coins Monedha',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (discount != null)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          discount,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (originalPrice != null)
                    Text(
                      originalPrice,
                      style: const TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF667eea),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<String> items) {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF667eea),
              ),
            ),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(item, style: const TextStyle(fontSize: 15)),
            )),
          ],
        ),
      ),
    );
  }

  void _purchasePro(BuildContext context, UserProfile profile, int months, double price) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmo Blerjen'),
          content: Text('Dëshiron të blesh PRO për $months muaj me €$price?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Anulo'),
            ),
            ElevatedButton(
              onPressed: () {
                // In production, this would integrate with payment system
                profile.upgradeToPro();
                profile.addCoins(months == 12 ? 1000 : months == 6 ? 500 : 100);
                SoundService.playCoin();
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🎉 Urime! Ti je PRO tani!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Konfirmo'),
            ),
          ],
        );
      },
    );
  }

  void _purchaseCoins(BuildContext context, UserProfile profile, int coins, String price) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmo Blerjen'),
          content: Text('Dëshiron të blesh $coins monedha me $price?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Anulo'),
            ),
            ElevatedButton(
              onPressed: () {
                // In production, integrate with payment
                profile.addCoins(coins);
                SoundService.playCoin();
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('🪙 Morët $coins monedha!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Konfirmo'),
            ),
          ],
        );
      },
    );
  }

  void _watchAdForCoins(BuildContext context, UserProfile profile) {
    AdService.showRewardedAd((coins) {
      profile.addCoins(coins);
      SoundService.playCoin();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 Morët $coins monedha!'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }
}
