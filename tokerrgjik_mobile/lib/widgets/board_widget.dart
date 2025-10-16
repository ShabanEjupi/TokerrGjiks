import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tokerrgjik_mobile/config.dart';
import 'package:tokerrgjik_mobile/models/game_state.dart';
import 'package:tokerrgjik_mobile/services/socket_service.dart';

class BoardWidget extends StatelessWidget {
  final SocketService socketService;
  const BoardWidget({super.key, required this.socketService});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    final board = gameState.board;

    return AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(
        painter: _BoardPainter(),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
          ),
          itemCount: 49,
          itemBuilder: (context, index) {
            final posId = _mapIndexToPosId(index);
            if (posId != null) {
              return GestureDetector(
                onTap: () => _handleTap(context, posId),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: board[posId] == 1
                        ? GameConfig.player1Color
                        : board[posId] == 2
                            ? GameConfig.player2Color
                            : Colors.transparent,
                    border: gameState.selectedPosition == posId
                        ? Border.all(color: GameConfig.accentColor, width: 3)
                        : null,
                  ),
                ),
              );
            }
            return Container();
          },
        ),
      ),
    );
  }

  void _handleTap(BuildContext context, int posId) {
    final gameState = Provider.of<GameState>(context, listen: false);
    if (!gameState.isMyTurn) return;

    // Logic for placing, moving, removing pieces
    // This is a simplified version. You'll need to implement the full game logic.
    if (gameState.phase == 'placing') {
      socketService.sendMove({'type': 'place', 'position': posId});
    } else if (gameState.phase == 'moving') {
      if (gameState.selectedPosition == null) {
        if (gameState.board[posId] == gameState.myPlayerNumber) {
          gameState.selectPosition(posId);
        }
      } else {
        socketService.sendMove({
          'type': 'move',
          'from': gameState.selectedPosition,
          'to': posId,
        });
        gameState.selectPosition(null);
      }
    } else if (gameState.phase == 'removing') {
       socketService.sendMove({'type': 'remove', 'position': posId});
    }
  }

  int? _mapIndexToPosId(int index) {
    // This mapping depends on your specific board layout
    // You need to create a mapping from GridView index to your BOARD_POSITIONS
    return null; // Placeholder
  }
}

class _BoardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = GameConfig.boardColor
      ..strokeWidth = 2;

    // Draw lines for the board
    // This is a simplified representation. You'll need to draw the actual board lines.
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
