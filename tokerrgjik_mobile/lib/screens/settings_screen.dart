import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../services/sound_service.dart';
import '../config/themes.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'developer_info_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cilësimet'),
        backgroundColor: const Color(0xFF667eea),
      ),
      body: Consumer<UserProfile>(
        builder: (context, profile, child) {
          return ListView(
            children: [
              // Sound Settings
              _buildSection(
                context,
                title: '🔊 Tinguj dhe muzikë',
                children: [
                  SwitchListTile(
                    title: const Text('Efektet e zërit'),
                    subtitle: const Text('Tinguj për lëvizje dhe veprime'),
                    value: profile.soundEnabled,
                    onChanged: (value) {
                      profile.updateSettings(sound: value);
                      SoundService.setSoundEnabled(value);
                      if (value) SoundService.playClick();
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Muzika e sfondit'),
                    subtitle: const Text('Muzikë gjatë lojës'),
                    value: profile.musicEnabled,
                    onChanged: (value) {
                      profile.updateSettings(music: value);
                      SoundService.setMusicEnabled(value);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Dridhje'),
                    subtitle: const Text('Feedback haptik për veprime'),
                    value: profile.vibrateEnabled,
                    onChanged: (value) {
                      profile.updateSettings(vibrate: value);
                    },
                  ),
                ],
              ),
              
              // Difficulty Settings
              _buildSection(
                context,
                title: '🎯 Vështirësitë e AI',
                children: [
                  RadioListTile<String>(
                    title: const Text('E lehtë'),
                    subtitle: const Text('Perfekt për fillestarë - 3 monedha për fitore'),
                    value: 'easy',
                    groupValue: profile.difficulty,
                    onChanged: (value) {
                      profile.updateSettings(difficulty: value);
                      SoundService.playClick();
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Mesatare'),
                    subtitle: const Text('Sfidë e balancuar - 5 monedha për fitore'),
                    value: 'medium',
                    groupValue: profile.difficulty,
                    onChanged: (value) {
                      profile.updateSettings(difficulty: value);
                      SoundService.playClick();
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('E vështirë'),
                    subtitle: const Text('Për lojtarë të përvojshëm - 8 monedha për fitore'),
                    value: 'hard',
                    groupValue: profile.difficulty,
                    onChanged: (value) {
                      profile.updateSettings(difficulty: value);
                      SoundService.playClick();
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Ekspert'),
                    subtitle: const Text('Sfida maksimale! - 12 monedha për fitore'),
                    value: 'expert',
                    groupValue: profile.difficulty,
                    onChanged: (value) {
                      profile.updateSettings(difficulty: value);
                      SoundService.playClick();
                    },
                  ),
                ],
              ),
              
              // Appearance
              _buildSection(
                context,
                title: '🎨 Pamja',
                children: [
                  ListTile(
                    title: const Text('Ngjyra e lojtarit 1'),
                    trailing: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: profile.player1Color,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey, width: 2),
                      ),
                    ),
                    onTap: () => _showColorPicker(
                      context,
                      profile.player1Color,
                      (color) => profile.updateTheme(player1: color),
                    ),
                  ),
                  ListTile(
                    title: const Text('Ngjyra e lojtarit 2'),
                    trailing: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: profile.player2Color,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey, width: 2),
                      ),
                    ),
                    onTap: () => _showColorPicker(
                      context,
                      profile.player2Color,
                      (color) => profile.updateTheme(player2: color),
                    ),
                  ),
                  ListTile(
                    title: const Text('Ngjyra e tabelës'),
                    trailing: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: profile.boardColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey, width: 2),
                      ),
                    ),
                    onTap: () => _showColorPicker(
                      context,
                      profile.boardColor,
                      (color) => profile.updateTheme(board: color),
                    ),
                  ),
                  ListTile(
                    title: const Text('Temë paravendosur'),
                    subtitle: Text('Aktuale: ${_getThemeName(profile.boardTheme)}'),
                    trailing: const Icon(Icons.palette),
                    onTap: () => _showThemeSelector(context, profile),
                  ),
                ],
              ),
              
              // Account
              _buildSection(
                context,
                title: '👤 Llogaria',
                children: [
                  ListTile(
                    title: const Text('Emri i lojtarit'),
                    subtitle: Text(profile.username),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _showUsernameDialog(context, profile),
                  ),
                  ListTile(
                    title: Text(
                      profile.isPro ? '✨ Llogari PRO' : 'Kalo në PRO',
                    ),
                    subtitle: Text(
                      profile.isPro 
                        ? 'Pa reklama, Themes ekskluzive' 
                        : 'Hiq reklamat dhe merr avantazhe',
                    ),
                    trailing: profile.isPro 
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : const Icon(Icons.arrow_forward),
                    onTap: profile.isPro ? null : () {
                      Navigator.pushNamed(context, '/shop');
                    },
                  ),
                ],
              ),
              
              // About
              _buildSection(
                context,
                title: 'ℹ️ Informacion',
                children: [
                  const ListTile(
                    title: Text('Versioni'),
                    subtitle: Text('1.0.0'),
                  ),
                  ListTile(
                    title: const Text('Zhvilluar nga'),
                    subtitle: const Text('DogaCode Solutions'),
                    trailing: const Icon(Icons.info_outline),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DeveloperInfoScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              
              // About / Developer Info
              _buildSection(
                context,
                title: 'ℹ️ Informacion',
                children: [
                  ListTile(
                    leading: const Icon(Icons.code, color: Color(0xFF667eea)),
                    title: const Text('Informacion për zhvilluesin'),
                    subtitle: const Text('Shiko detajet e aplikacionit'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DeveloperInfoScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.info_outline, color: Color(0xFF667eea)),
                    title: const Text('Versioni i aplikacionit'),
                    subtitle: const Text('1.0.0'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildSection(BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF667eea),
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(children: children),
        ),
      ],
    );
  }
  
  String _getThemeName(String theme) {
    return AppThemes.getShortName(theme);
  }
  
  void _showColorPicker(BuildContext context, Color current, Function(Color) onColorChanged) {
    showDialog(
      context: context,
      builder: (context) {
        Color pickerColor = current;
        return AlertDialog(
          title: const Text('Zgjedh ngjyrën'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (color) {
                pickerColor = color;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Anulo'),
            ),
            ElevatedButton(
              onPressed: () {
                onColorChanged(pickerColor);
                Navigator.pop(context);
              },
              child: const Text('Ruaj'),
            ),
          ],
        );
      },
    );
  }
  
  void _showThemeSelector(BuildContext context, UserProfile profile) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Zgjedh temën'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: AppThemes.themeKeys.map((key) {
                final theme = AppThemes.getTheme(key);
                return _themeOptionNew(context, key, theme, profile);
              }).toList(),
            ),
          ),
        );
      },
    );
  }
  
  Widget _themeOptionNew(BuildContext context, String key, GameTheme theme, UserProfile profile) {
    bool isSelected = profile.boardTheme == key;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.withAlpha(25) : null,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        title: Text(
          theme.name,
          style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
        ),
        subtitle: Text(theme.description, style: const TextStyle(fontSize: 12)),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: theme.boardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.player1Color,
                  border: Border.all(color: Colors.black),
                ),
              ),
              Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.player2Color,
                  border: Border.all(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
        onTap: () {
          profile.updateTheme(
            theme: key,
            board: theme.boardColor,
            player1: theme.player1Color,
            player2: theme.player2Color,
          );
          SoundService.playClick();
          Navigator.pop(context);
        },
      ),
    );
  }
  
  void _showUsernameDialog(BuildContext context, UserProfile profile) {
    final controller = TextEditingController(text: profile.username);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ndrysho emrin'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Emri i ri',
              border: OutlineInputBorder(),
            ),
            maxLength: 20,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Anulo'),
            ),
            ElevatedButton(
              onPressed: () {
                // Update username - would need to add this to UserProfile
                Navigator.pop(context);
              },
              child: const Text('Ruaj'),
            ),
          ],
        );
      },
    );
  }
}
