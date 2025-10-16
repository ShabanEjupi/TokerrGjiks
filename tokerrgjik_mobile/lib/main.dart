import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tokerrgjik_mobile/models/game_state.dart';
import 'package:tokerrgjik_mobile/models/user_profile.dart';
import 'package:tokerrgjik_mobile/services/ad_service.dart';  // Now using stub implementation
import 'package:tokerrgjik_mobile/services/sound_service.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/friends_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services (with error handling)
  // AdService disabled - requires proper AdMob App ID configuration
  // To enable: Add your AdMob App ID to AndroidManifest.xml and uncomment below
  // try {
  //   await AdService.initialize();
  // } catch (e) {
  //   print('Ad initialization skipped: $e');
  // }
  
  SoundService.initialize();
  
  // Lock to portrait mode for better gameplay
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set status bar color
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const TokerrgjikApp());
}

class TokerrgjikApp extends StatelessWidget {
  const TokerrgjikApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => GameState()),
        ChangeNotifierProvider(
          create: (context) => UserProfile()..loadProfile(),
        ),
      ],
      child: MaterialApp(
        title: 'Tokerrgjik',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: const HomeScreen(),
        routes: {
          '/settings': (context) => const SettingsScreen(),
          '/shop': (context) => const ShopScreen(),
          '/leaderboard': (context) => const LeaderboardScreen(),
          '/friends': (context) => const FriendsScreen(),
        },
      ),
    );
  }
}
