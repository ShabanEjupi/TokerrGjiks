import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../models/game_model.dart';
import '../services/sound_service.dart';

class HintData {
  final String text;
  final int? position;
  
  HintData(this.text, this.position);
}

/// Hints Service for TokerrGjik
/// Provides strategic hints during gameplay for coins
class HintsService {
  static const int HINT_COST = 10; // 10 coins per hint
  
  /// Get a strategic hint for the current game state
  static HintData? getHint(GameModel game, int currentPlayer) {
    // PLACING PHASE HINTS
    if (game.phase == 'placing') {
      // Check if we can complete a mill
      List<int> emptyPositions = [];
      for (int i = 0; i < 24; i++) {
        if (game.board[i] == null) emptyPositions.add(i);
      }
      
      for (int pos in emptyPositions) {
        game.board[pos] = currentPlayer;
        if (game.checkMill(pos)) {
          game.board[pos] = null;
          return HintData('💡 Vendose figurën në pozicionin ${_getPositionName(pos)} për të formuar një rreth!', pos);
        }
        game.board[pos] = null;
      }
      
      // Check if we can block opponent's mill
      int opponent = currentPlayer == 1 ? 2 : 1;
      for (int pos in emptyPositions) {
        game.board[pos] = opponent;
        if (game.checkMill(pos)) {
          game.board[pos] = null;
          return HintData('🛡️ Bllokoj kundërshtarin duke vendosur në pozicionin ${_getPositionName(pos)}!', pos);
        }
        game.board[pos] = null;
      }
      
      // Strategic positions advice
      List<int> strategic = [1, 3, 5, 7, 9, 11, 13, 15]; // Center and middle positions
      List<int> availableStrategic = emptyPositions.where((pos) => strategic.contains(pos)).toList();
      if (availableStrategic.isNotEmpty) {
        return HintData('⭐ Pozicionet strategjike: ${_getPositionName(availableStrategic.first)} janë më të mira!', availableStrategic.first);
      }
      
      return HintData('💭 Vendos figurat në qendër për fleksibilitet maksimal!', null);
    }
    
    // MOVING PHASE HINTS
    if (game.phase == 'moving') {
      List<int> playerPieces = [];
      for (int i = 0; i < 24; i++) {
        if (game.board[i] == currentPlayer) playerPieces.add(i);
      }
      
      // Check if we can form a mill by moving
      for (int from in playerPieces) {
        List<int> moves = game.getValidMoves(from);
        for (int to in moves) {
          int? temp = game.board[from];
          game.board[from] = null;
          game.board[to] = temp;
          if (game.checkMill(to)) {
            game.board[from] = temp;
            game.board[to] = null;
            return HintData('🎯 Lëviz figurën nga ${_getPositionName(from)} në ${_getPositionName(to)} për të formuar rreth!', to);
          }
          game.board[from] = temp;
          game.board[to] = null;
        }
      }
      
      // Check if we can block opponent's potential mill
      int opponent = currentPlayer == 1 ? 2 : 1;
      for (int from in playerPieces) {
        List<int> moves = game.getValidMoves(from);
        for (int to in moves) {
          game.board[to] = opponent;
          if (game.checkMill(to)) {
            game.board[to] = null;
            return HintData('🛡️ Bllokoj lëvizjen e kundërshtarit duke lëvizur në ${_getPositionName(to)}!', to);
          }
          game.board[to] = null;
        }
      }
      
      return HintData('🤔 Kërko të formosh rrathë duke lëvizur figurat në pozicione strategjike!', null);
    }
    
    // REMOVING PHASE HINTS
    if (game.phase == 'removing') {
      List<int> removable = game.getRemovablePieces();
      
      if (removable.isEmpty) {
        return HintData('⚠️ Të gjitha figurat e kundërshtarit janë në rrathë. Mund të heqësh çdo figurë!', null);
      }
      
      // Prioritize removing pieces that are close to forming mills
      int opponent = currentPlayer == 1 ? 2 : 1;
      for (int pos in removable) {
        // Check if opponent has 2/3 of a mill here
        for (List<int> mill in GameModel.mills) {
          if (mill.contains(pos)) {
            int opponentCount = 0;
            int emptyCount = 0;
            for (int p in mill) {
              if (game.board[p] == opponent) opponentCount++;
              if (game.board[p] == null) emptyCount++;
            }
            if (opponentCount == 2 && emptyCount == 1) {
              return HintData('⭐ Hiq figurën nga ${_getPositionName(pos)} për të shkatërruar një rreth të mundshëm!', pos);
            }
          }
        }
      }
      
      return HintData('💡 Hiq figurën e kundërshtarit nga një pozicion strategjik!', null);
    }
    
    return null;
  }
  
  /// Show hint dialog and return the hint position for visual highlighting
  static Future<int?> showHintDialog(BuildContext context, GameModel game, int currentPlayer) async {
    final profile = Provider.of<UserProfile>(context, listen: false);
    
    if (profile.coins < HINT_COST) {
      _showInsufficientCoinsDialog(context);
      return null;
    }
    
    final hintData = getHint(game, currentPlayer);
    if (hintData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Asnjë hint i disponueshëm për këtë situatë!')),
      );
      return null;
    }
    
    return await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lightbulb, color: Colors.amber, size: 32),
            SizedBox(width: 8),
            Text('Hint Strategjik'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              hintData.text,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.monetization_on, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '$HINT_COST monedha',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Anulo'),
          ),
          ElevatedButton(
            onPressed: () {
              if (profile.spendCoins(HINT_COST)) {
                SoundService.playCoin();
                Navigator.pop(context, hintData.position);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✨ Hint i blerë!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Blej Hint'),
          ),
        ],
      ),
    );
  }
  
  static void _showInsufficientCoinsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Monedha të pamjaftueshme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Nevojiten $HINT_COST monedha për një hint.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Luan më shumë lojëra ose bli monedha nga dyqani!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mbyll'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/shop');
            },
            child: const Text('Shko te Dyqani'),
          ),
        ],
      ),
    );
  }
  
  static String _getPositionName(int pos) {
    // Return human-readable position names
    if (pos >= 0 && pos <= 7) return 'Katrori i jashtëm #${pos + 1}';
    if (pos >= 8 && pos <= 15) return 'Katrori i mesëm #${pos - 7}';
    if (pos >= 16 && pos <= 23) return 'Katrori i brendshëm #${pos - 15}';
    return '#$pos';
  }
}
