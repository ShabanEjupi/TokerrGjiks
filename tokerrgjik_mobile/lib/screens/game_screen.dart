import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_model.dart';
import '../models/user_profile.dart';
import '../widgets/game_board.dart';
import '../services/sound_service.dart';
import '../services/notification_service.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import '../services/auth_service.dart';
import '../services/hints_service.dart';

class GameScreen extends StatefulWidget {
  final String? mode;
  final String? difficulty;
  
  const GameScreen({super.key, this.mode, this.difficulty});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameModel game;
  int _player1Mills = 0; // Track mills formed by player 1
  int _coinsEarned = 0; // Track coins earned this game

  @override
  void initState() {
    super.initState();
    game = GameModel();
    game.reset(); // Initialize history
    _player1Mills = 0;
    _coinsEarned = 0;
    
    // Set up bonus callback for shilevek rewards
    game.onBonusEarned = (int coins, String reason) {
      _coinsEarned += coins;
      _showBonusNotification(coins, reason);
      // Update user coins in profile
      _awardCoins(coins);
    };
    
    // Configure game based on mode and difficulty
    if (widget.mode == 'ai' && widget.difficulty != null) {
      game.aiEnabled = true;
    } else if (widget.mode == 'online') {
      // Configure for online play
    }
    // 'local' mode uses default settings
  }

  void handlePositionTap(int posId) {
    // Don't allow input during AI's turn
    if (game.aiEnabled && game.currentPlayer == game.aiPlayer) {
      return;
    }

    setState(() {
      if (game.phase == 'placing') {
        bool millFormed = game.placePiece(posId);
        SoundService.playPlacePiece();
        if (millFormed) {
          SoundService.playMill();
          // Award coins for mill if player 1 formed it
          if (game.currentPlayer == 1) {
            _player1Mills++;
            _awardCoins(2, 'Dang u formua! +2 monedha 🎯');
          }
          // Player must remove an opponent's piece - don't trigger AI yet
        } else if (!game.checkWinCondition()) {
          // Turn automatically switched in placePiece() - trigger AI if needed
          _notifyTurnChange();
          _makeAIMoveIfNeeded();
        }
      } else if (game.phase == 'moving') {
        if (game.selectedPosition == null) {
          // First click: Select a piece to move
          if (game.board[posId] == game.currentPlayer) {
            game.selectedPosition = posId;
            SoundService.playClick();
          }
        } else {
          // Second click: Move the piece or deselect
          if (posId == game.selectedPosition) {
            // Clicking same position deselects
            game.selectedPosition = null;
            SoundService.playClick();
          } else if (game.board[posId] == game.currentPlayer) {
            // Clicking on another own piece, select it instead
            game.selectedPosition = posId;
            SoundService.playClick();
          } else if (game.board[posId] == null) {
            // Only try to move if target position is empty
            List<int> validMoves = game.getValidMoves(game.selectedPosition!);
            
            if (validMoves.contains(posId)) {
              // This is a valid move
              bool millFormed = game.movePiece(game.selectedPosition!, posId);
              SoundService.playMovePiece();
              game.selectedPosition = null;
              
              if (millFormed) {
                SoundService.playMill();
                // Award coins for mill if player 1 formed it
                if (game.currentPlayer == 1) {
                  _player1Mills++;
                  _awardCoins(2, 'Dang u formua! +2 monedha 🎯');
                }
                // Player must remove an opponent's piece - don't trigger AI yet
              } else if (!game.checkWinCondition()) {
                // Turn automatically switched in movePiece() - trigger AI if needed
                _notifyTurnChange();
                _makeAIMoveIfNeeded();
              }
            } else {
              // Invalid move - must move to adjacent position or use flying rules
              game.selectedPosition = null;
              SoundService.playClick();
            }
          } else {
            // Clicked on opponent's piece - deselect
            game.selectedPosition = null;
            SoundService.playClick();
          }
        }
      } else if (game.phase == 'removing') {
        bool removed = game.removePiece(posId);
        if (removed) {
          SoundService.playRemovePiece();
          if (!game.checkWinCondition()) {
            // Turn automatically switched in removePiece() - trigger AI if needed
            _notifyTurnChange();
            _makeAIMoveIfNeeded();
          }
        }
      }
      
      // Check for win
      if (game.checkWinCondition()) {
        SoundService.playWin();
        _showWinDialog();
      }
    });
  }

  void _notifyTurnChange() {
    // Notify when turn changes
    if (game.aiEnabled && game.currentPlayer != game.aiPlayer) {
      // AI just finished, notify human player
      NotificationService.notifyPlayerTurn(game.currentPlayer, isAI: true);
    } else if (!game.aiEnabled) {
      // Local multiplayer - notify whose turn it is
      NotificationService.notifyPlayerTurn(game.currentPlayer);
    }
  }

  void _makeAIMoveIfNeeded() {
    if (game.aiEnabled && game.currentPlayer == game.aiPlayer) {
      // Show AI thinking notification
      NotificationService.notifyAIThinking();
      
      // Add timeout protection - max 3 seconds for AI to make a move
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        
        // Set a timeout in case AI gets stuck
        bool moveCompleted = false;
        
        Future.delayed(const Duration(seconds: 3), () {
          if (!mounted || moveCompleted) return;
          // Timeout - AI didn't move, force a random move or switch player
          print('AI move timeout - forcing fallback');
          if (mounted) {
            setState(() {
              // Force switch player if AI is stuck
              game.switchPlayer();
            });
          }
        });
        
        setState(() {
          try {
            game.makeAIMove();
            moveCompleted = true;
            
            // Cancel AI thinking notification
            NotificationService.cancelAIThinking();
            
            // If AI formed a mill during placement/moving, it needs to remove a piece
            // The phase will be 'removing' and currentPlayer will still be the AI
            if (game.phase == 'removing' && game.currentPlayer == game.aiPlayer) {
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) {
                  setState(() {
                    game.makeAIMove(); // AI removes opponent's piece
                    // removePiece() already switches player, don't switch again
                    // Just check for win condition
                    NotificationService.cancelAIThinking();
                    if (game.checkWinCondition()) {
                      SoundService.playWin();
                      _showWinDialog();
                    } else {
                      // Notify human player it's their turn
                      NotificationService.notifyPlayerTurn(game.currentPlayer, isAI: true);
                    }
                  });
                }
              });
            } else if (game.checkWinCondition()) {
              // Check for win after AI's move
              SoundService.playWin();
              _showWinDialog();
            } else {
              // Notify human player it's their turn
              NotificationService.notifyPlayerTurn(game.currentPlayer, isAI: true);
            }
          } catch (e) {
            // If AI move fails, switch to player
            print('AI move error: $e');
            game.switchPlayer();
            NotificationService.cancelAIThinking();
          }
        });
      });
    }
  }

  void resetGame() {
    setState(() {
      game.reset();
      _player1Mills = 0;
      _coinsEarned = 0;
    });
  }

  void toggleAI() {
    setState(() {
      game.aiEnabled = !game.aiEnabled;
      
      if (game.aiEnabled && game.currentPlayer == game.aiPlayer) {
        _makeAIMoveIfNeeded();
      }
    });
  }

  void _undo() {
    if (game.canUndo()) {
      setState(() {
        game.undo();
        SoundService.playClick();
      });
    }
  }

  void _redo() {
    if (game.canRedo()) {
      setState(() {
        game.redo();
        SoundService.playClick();
      });
    }
  }

  void _awardCoins(int amount, String message) {
    setState(() {
      _coinsEarned += amount;
    });
    
    // Update user profile immediately
    final profile = Provider.of<UserProfile>(context, listen: false);
    profile.addCoins(amount);
    
    // Show snackbar notification
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showSurrenderDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dorëzohesh?'),
        content: Text('Lojtari ${game.currentPlayer == 1 ? 2 : 1} do të fitojë!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anulo'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Return to home
              SoundService.playLose();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Dorëzohu'),
          ),
        ],
      ),
    );
  }


  void _showWinDialog() {
    // checkWinCondition() returns true when the OPPONENT of currentPlayer has lost
    // This means currentPlayer is the WINNER (not the loser)
    final winner = game.currentPlayer; // Current player is the winner!
    
    // Check for shilevek bonus (opponent reduced to exactly 3 pieces)
    final loser = winner == 1 ? 2 : 1;
    final bool isShilevek = game.piecesOnBoard[loser] == 3;
    
    // Award shilevek bonus if player 1 wins
    if (winner == 1 && isShilevek) {
      _awardCoins(20, 'SHILEVEK! +20 monedha bonus! 🌟');
    }
    
    // Determine winner name and dialog style based on game mode
    String winnerName;
    String contentMessage;
    IconData dialogIcon;
    Color dialogColor;
    
    if (game.aiEnabled) {
      // In AI mode: Player 1 is always the student, Player 2 is AI
      if (winner == 1) {
        winnerName = '🎉 Ti fitove!'; // Student won
        dialogIcon = Icons.emoji_events;
        dialogColor = Colors.green;
        contentMessage = 'Urime për fitoren!\n\n'
            '🎯 Mills: $_player1Mills x 2 = ${_player1Mills * 2} monedha\n'
            '${isShilevek ? "🌟 Shilevek bonus: +20 monedha\n" : ""}'
            '💰 Total monedha fituar: $_coinsEarned';
      } else {
        winnerName = '😔 AI fitoi!'; // AI won
        dialogIcon = Icons.sentiment_dissatisfied;
        dialogColor = Colors.red;
        contentMessage = 'AI ishte më i fortë këtë herë!\n\nProvoje përsëri dhe fito!';
      }
    } else {
      // In local multiplayer mode
      winnerName = winner == 1 ? '🎉 Lojtari 1 fitoi!' : '🎮 Lojtari 2 fitoi!';
      dialogIcon = Icons.emoji_events;
      dialogColor = winner == 1 ? Colors.green : Colors.blue;
      contentMessage = winner == 1 
          ? 'Mills: $_player1Mills\n${isShilevek ? "Shilevek bonus! 🌟\n" : ""}Monedha fituar: $_coinsEarned'
          : 'Urime për fitoren!';
    }
    
    // Save result before showing dialog
    _saveResultForWinner(winner);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(dialogIcon, color: dialogColor, size: 32),
            const SizedBox(width: 12),
            Expanded(child: Text(winnerName, style: TextStyle(color: dialogColor))),
          ],
        ),
        content: Text(contentMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Kthehu'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              resetGame();
            },
            child: const Text('Lojë e re'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveResultForWinner(int winner) async {
    final username = AuthService.currentUsername ?? Provider.of<UserProfile>(context, listen: false).username;
    String result = 'draw';
    String? opponent;

    if (game.aiEnabled) {
      if (winner == 1) result = 'win'; else result = 'loss';
      opponent = 'AI';
    } else {
      // Local multiplayer: winner is player 1 or 2
      if (winner == 1) result = 'win'; else result = 'loss';
      opponent = 'player_${winner == 1 ? 2 : 1}';
    }

    // Update local profile immediately
    final profile = Provider.of<UserProfile>(context, listen: false);
    if (result == 'win') profile.recordWin();
    else if (result == 'loss') profile.recordLoss();
    else profile.recordDraw();

    // Try to send to server; if fails, save locally
    try {
      await ApiService.saveGameResult(
        username: username,
        gameMode: widget.mode ?? (game.aiEnabled ? 'vs_ai' : 'local'),
        result: result,
        opponentUsername: opponent,
      );
    } catch (e) {
      final local = LocalStorageService();
      await local.init();
      await local.saveGameHistory({
        'username': username,
        'game_mode': widget.mode ?? (game.aiEnabled ? 'vs_ai' : 'local'),
        'result': result,
        'opponent_username': opponent,
        'played_at': DateTime.now().toIso8601String(),
      });
    }
  }

  void showRules() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Si të luash tokerrgjik',
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
                  'Formo "rrathë" (3 figura në radhë) për të hequr figurat e kundërshtarit.',
                ),
                const SizedBox(height: 15),
                _buildRuleSection(
                  '📝 Fazat',
                  '1. Vendos 9 figurat\n2. Lëviz figurat\n3. Fluturim me 3 figura',
                ),
                const SizedBox(height: 15),
                _buildRuleSection(
                  '🏆 Fitimi',
                  'Zvogëlo kundërshtarin në 2 figura ose bllokoj lëvizjet.',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Mbyll'),
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
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get user profile for theme colors
    final profile = Provider.of<UserProfile>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🎮 Tokerrgjik',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Hints button - only show in placing and moving phases
          if (game.phase != 'removing' && game.phase != 'gameover')
            IconButton(
              icon: Stack(
                children: [
                  const Icon(Icons.lightbulb_outline),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 14,
                        minHeight: 14,
                      ),
                      child: Text(
                        '${HintsService.HINT_COST}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              onPressed: () => HintsService.showHintDialog(context, game, game.currentPlayer),
              tooltip: 'Blej Hint (${HintsService.HINT_COST} monedha)',
            ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
            tooltip: 'Cilësimet (për temën)',
          ),
          IconButton(
            icon: const Icon(Icons.flag),
            onPressed: _showSurrenderDialog,
            tooltip: 'Dorëzohu',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              profile.boardColor,
              Colors.white,
            ],
            stops: const [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                children: [
                  // Player info
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildPlayerInfo(1),
                        _buildPlayerInfo(2),
                      ],
                    ),
                  ),

              // Status message
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  game.getStatusMessage(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 8),

              // Game board - takes remaining space
              Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Use 90% of available width or height (whichever is smaller)
                    final size = constraints.maxWidth < constraints.maxHeight
                        ? constraints.maxWidth * 0.90
                        : constraints.maxHeight * 0.90;
                    
                    return SizedBox(
                      width: size,
                      height: size,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GameBoard(
                          game: game,
                          onPositionTap: handlePositionTap,
                          boardColor: profile.boardColor,
                          player1Color: profile.player1Color,
                          player2Color: profile.player2Color,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),

              // Undo/Redo buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: game.canUndo() ? _undo : null,
                      icon: const Icon(Icons.undo),
                      color: game.canUndo() ? const Color(0xFF667eea) : Colors.grey,
                      iconSize: 32,
                      tooltip: 'Zhbëj',
                    ),
                    const SizedBox(width: 24),
                    IconButton(
                      onPressed: game.canRedo() ? _redo : null,
                      icon: const Icon(Icons.redo),
                      color: game.canRedo() ? const Color(0xFF667eea) : Colors.grey,
                      iconSize: 32,
                      tooltip: 'Ribëj',
                    ),
                  ],
                ),
              ),

              // Control buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildSmallButton(
                      icon: game.aiEnabled ? Icons.person : Icons.smart_toy,
                      label: game.aiEnabled ? 'Njeri' : 'AI',
                      onPressed: toggleAI,
                      color: game.aiEnabled ? Colors.red : Colors.blue,
                    ),
                    _buildSmallButton(
                      icon: Icons.refresh,
                      label: 'E re',
                      onPressed: resetGame,
                      color: const Color(0xFF667eea),
                    ),
                    _buildSmallButton(
                      icon: Icons.menu_book,
                      label: 'Rregullat',
                      onPressed: showRules,
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSmallButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        minimumSize: const Size(95, 40),
      ),
    );
  }

  Widget _buildPlayerInfo(int player) {
    final profile = Provider.of<UserProfile>(context, listen: false);
    bool isActive = game.currentPlayer == player;
    bool isAI = game.aiEnabled && player == game.aiPlayer;
    int piecesCount = game.piecesLeft[player]! > 0
        ? game.piecesLeft[player]!
        : game.piecesOnBoard[player]!;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white70,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: player == 1 
                  ? profile.player1Color
                  : profile.player2Color,
              border: Border.all(color: Colors.black87, width: 2),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'P$player ${isAI ? '🤖' : ''}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isActive ? const Color(0xFF667eea) : Colors.grey,
                ),
              ),
              Text(
                'Figura: $piecesCount',
                style: const TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Show bonus notification for shilevek mastery
  void _showBonusNotification(int coins, String reason) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.stars, color: Colors.amber, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    reason,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '+$coins coins for exceptional play!',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Award coins to the user profile
  Future<void> _awardCoins(int coins) async {
    try {
      final profile = Provider.of<UserProfile>(context, listen: false);
      await profile.addCoins(coins);
    } catch (e) {
      print('Error awarding coins: $e');
    }
  }
}
