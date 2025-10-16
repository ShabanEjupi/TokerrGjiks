import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tokerrgjik_mobile/models/game_state.dart';

class PlayerInfoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildPlayerInfo(context, 'Player 1', gameState.piecesLeft[1] ?? 9, gameState.currentPlayer == 1),
        _buildPlayerInfo(context, 'Player 2', gameState.piecesLeft[2] ?? 9, gameState.currentPlayer == 2),
      ],
    );
  }

  Widget _buildPlayerInfo(BuildContext context, String name, int pieces, bool isCurrent) {
    return Column(
      children: [
        Text(name, style: TextStyle(fontSize: 18, fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal)),
        Text('Pieces left: $pieces'),
      ],
    );
  }
}
