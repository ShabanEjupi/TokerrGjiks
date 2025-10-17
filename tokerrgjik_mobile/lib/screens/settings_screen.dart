import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../services/sound_service.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

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
                title: '🎯 Vështirësia e AI',
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
                    title: const Text('Ngjyra e Bordit'),
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
                      profile.isPro ? '✨ Llogari PRO' : 'Përmirëso në PRO',
                    ),
                    subtitle: Text(
                      profile.isPro 
                        ? 'Pa reklama, tema ekskluzive' 
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
                  const ListTile(
                    title: Text('Zhvilluar nga'),
                    subtitle: Text('AlbaCode Solutions'),
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
    switch (theme) {
      case 'classic':
        return 'Klasike';
      case 'modern':
        return 'Moderne';
      case 'dark':
        return 'E Errët';
      case 'custom':
        return 'E Personalizuar';
      default:
        return theme;
    }
  }
  
  void _showColorPicker(BuildContext context, Color current, Function(Color) onColorChanged) {
    showDialog(
      context: context,
      builder: (context) {
        Color pickerColor = current;
        return AlertDialog(
          title: const Text('Zgjedh Ngjyrën'),
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _themeOption(context, 'Klasike', 'classic', profile),
              _themeOption(context, 'Moderne', 'modern', profile),
              _themeOption(context, 'E Errët', 'dark', profile),
            ],
          ),
        );
      },
    );
  }
  
  Widget _themeOption(BuildContext context, String name, String value, UserProfile profile) {
    return ListTile(
      title: Text(name),
      leading: Radio<String>(
        value: value,
        groupValue: profile.boardTheme,
        onChanged: (val) {
          if (val != null) {
            profile.updateTheme(theme: val);
            Navigator.pop(context);
          }
        },
      ),
      onTap: () {
        profile.updateTheme(theme: value);
        Navigator.pop(context);
      },
    );
  }
  
  void _showUsernameDialog(BuildContext context, UserProfile profile) {
    final controller = TextEditingController(text: profile.username);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ndrysho Emrin'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Emri i Ri',
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
