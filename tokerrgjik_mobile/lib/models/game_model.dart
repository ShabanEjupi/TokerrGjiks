import 'dart:math';

class Position {
  final double x;
  final double y;
  final int id;

  Position({required this.x, required this.y, required this.id});
}

class GameModel {
  // Board state
  List<int?> board = List.filled(24, null);
  int currentPlayer = 1;
  String phase = 'placing'; // placing, moving, removing
  Map<int, int> piecesLeft = {1: 9, 2: 9};
  Map<int, int> piecesOnBoard = {1: 0, 2: 0};
  int? selectedPosition;
  bool aiEnabled = false;
  int aiPlayer = 2;
  
  // Undo/Redo functionality
  final List<GameSnapshot> _history = [];
  final List<GameSnapshot> _redoStack = [];
  static const int maxHistorySize = 50;
  
  // Helper class to store game state
  GameSnapshot _captureState() {
    return GameSnapshot(
      board: List.from(board),
      currentPlayer: currentPlayer,
      phase: phase,
      piecesLeft: Map.from(piecesLeft),
      piecesOnBoard: Map.from(piecesOnBoard),
    );
  }
  
  void _saveState() {
    _history.add(_captureState());
    if (_history.length > maxHistorySize) {
      _history.removeAt(0);
    }
    _redoStack.clear(); // Clear redo stack on new action
  }
  
  bool canUndo() => _history.length > 1;
  bool canRedo() => _redoStack.isNotEmpty;
  
  void undo() {
    if (!canUndo()) return;
    
    // Save current state to redo stack
    _redoStack.add(_captureState());
    
    // Remove current state
    _history.removeLast();
    
    // Restore previous state
    final previousState = _history.last;
    _restoreState(previousState);
  }
  
  void redo() {
    if (!canRedo()) return;
    
    // Save current state to history
    _history.add(_captureState());
    
    // Restore state from redo stack
    final nextState = _redoStack.removeLast();
    _restoreState(nextState);
  }
  
  void _restoreState(GameSnapshot state) {
    board = List.from(state.board);
    currentPlayer = state.currentPlayer;
    phase = state.phase;
    piecesLeft = Map.from(state.piecesLeft);
    piecesOnBoard = Map.from(state.piecesOnBoard);
    selectedPosition = null;
  }

  // Board positions (normalized 0-1 coordinates)
  static final List<Position> positions = [
    // Outer square (0-7)
    Position(x: 0.1, y: 0.1, id: 0),
    Position(x: 0.5, y: 0.1, id: 1),
    Position(x: 0.9, y: 0.1, id: 2),
    Position(x: 0.9, y: 0.5, id: 3),
    Position(x: 0.9, y: 0.9, id: 4),
    Position(x: 0.5, y: 0.9, id: 5),
    Position(x: 0.1, y: 0.9, id: 6),
    Position(x: 0.1, y: 0.5, id: 7),
    // Middle square (8-15)
    Position(x: 0.25, y: 0.25, id: 8),
    Position(x: 0.5, y: 0.25, id: 9),
    Position(x: 0.75, y: 0.25, id: 10),
    Position(x: 0.75, y: 0.5, id: 11),
    Position(x: 0.75, y: 0.75, id: 12),
    Position(x: 0.5, y: 0.75, id: 13),
    Position(x: 0.25, y: 0.75, id: 14),
    Position(x: 0.25, y: 0.5, id: 15),
    // Inner square (16-23)
    Position(x: 0.4, y: 0.4, id: 16),
    Position(x: 0.5, y: 0.4, id: 17),
    Position(x: 0.6, y: 0.4, id: 18),
    Position(x: 0.6, y: 0.5, id: 19),
    Position(x: 0.6, y: 0.6, id: 20),
    Position(x: 0.5, y: 0.6, id: 21),
    Position(x: 0.4, y: 0.6, id: 22),
    Position(x: 0.4, y: 0.5, id: 23),
  ];

  // Connections between positions
  static final Map<int, List<int>> connections = {
    0: [1, 7], 1: [0, 2, 9], 2: [1, 3], 3: [2, 4, 11],
    4: [3, 5], 5: [4, 6, 13], 6: [5, 7], 7: [6, 0, 15],
    8: [9, 15], 9: [8, 10, 1, 17], 10: [9, 11], 11: [10, 12, 3, 19],
    12: [11, 13], 13: [12, 14, 5, 21], 14: [13, 15], 15: [14, 8, 7, 23],
    16: [17, 23], 17: [16, 18, 9], 18: [17, 19], 19: [18, 20, 11],
    20: [19, 21], 21: [20, 22, 13], 22: [21, 23], 23: [22, 16, 15]
  };

  // All possible mills
  static final List<List<int>> mills = [
    [0, 1, 2], [2, 3, 4], [4, 5, 6], [6, 7, 0],
    [8, 9, 10], [10, 11, 12], [12, 13, 14], [14, 15, 8],
    [16, 17, 18], [18, 19, 20], [20, 21, 22], [22, 23, 16],
    [1, 9, 17], [3, 11, 19], [5, 13, 21], [7, 15, 23]
  ];

  // Place a piece on the board
  bool placePiece(int posId) {
    if (board[posId] != null) return false;
    if (piecesLeft[currentPlayer]! == 0) return false;

    _saveState(); // Save state before making move
    
    board[posId] = currentPlayer;
    piecesLeft[currentPlayer] = piecesLeft[currentPlayer]! - 1;
    piecesOnBoard[currentPlayer] = piecesOnBoard[currentPlayer]! + 1;

    if (checkMill(posId)) {
      phase = 'removing';
      return true; // Mill formed - DO NOT switch player, they must remove a piece
    }

    // Check if placement phase is over
    if (piecesLeft[1]! == 0 && piecesLeft[2]! == 0) {
      phase = 'moving';
    }

    // No mill - automatically switch to next player
    switchPlayer();
    return false; // No mill
  }

  // Move a piece
  bool movePiece(int from, int to) {
    if (board[from] != currentPlayer) return false;
    if (board[to] != null) return false;

    _saveState(); // Save state before making move
    
    // Check if move is valid
    bool canFly = piecesOnBoard[currentPlayer]! == 3;
    bool isAdjacent = connections[from]?.contains(to) ?? false;

    if (!canFly && !isAdjacent) return false;

    // Make the move
    board[to] = board[from];
    board[from] = null;

    if (checkMill(to)) {
      phase = 'removing';
      return true; // Mill formed - DO NOT switch player, they must remove a piece
    }

    // No mill - automatically switch to next player
    switchPlayer();
    return false; // No mill
  }

  // Remove opponent's piece
  bool removePiece(int posId) {
    int opponent = currentPlayer == 1 ? 2 : 1;

    if (board[posId] != opponent) return false;

    _saveState(); // Save state before making move
    
    // Check if piece is in a mill
    bool inMill = checkMill(posId);
    if (inMill) {
      // Check if all opponent pieces are in mills
      bool hasNonMillPieces = false;
      for (int i = 0; i < 24; i++) {
        if (board[i] == opponent && !checkMill(i)) {
          hasNonMillPieces = true;
          break;
        }
      }
      if (hasNonMillPieces) return false; // Can't remove piece in mill
    }

    board[posId] = null;
    piecesOnBoard[opponent] = piecesOnBoard[opponent]! - 1;

    // Return to appropriate phase and switch player
    if (piecesLeft[1]! == 0 && piecesLeft[2]! == 0) {
      phase = 'moving';
    } else {
      phase = 'placing';
    }
    
    // After removing opponent's piece, switch to opponent's turn
    switchPlayer();

    return true;
  }

  // Check if position forms a mill
  bool checkMill(int posId) {
    int? player = board[posId];
    if (player == null) return false;

    return mills.any((mill) =>
        mill.contains(posId) && mill.every((pos) => board[pos] == player));
  }

  // Check win condition
  bool checkWinCondition() {
    int opponent = currentPlayer == 1 ? 2 : 1;

    // Win if opponent has only 2 pieces
    if (piecesOnBoard[opponent]! < 3 && piecesLeft[opponent]! == 0) {
      return true;
    }

    // Win if opponent cannot move (in moving phase)
    if (phase == 'moving' && piecesLeft[opponent]! == 0) {
      bool canMove = false;
      for (int i = 0; i < 24; i++) {
        if (board[i] == opponent) {
          // Check if this piece can move
          if (piecesOnBoard[opponent]! == 3) {
            // Can fly to any empty position
            if (board.any((piece) => piece == null)) {
              canMove = true;
              break;
            }
          } else {
            // Check adjacent positions
            List<int>? adjacent = connections[i];
            if (adjacent != null &&
                adjacent.any((pos) => board[pos] == null)) {
              canMove = true;
              break;
            }
          }
        }
      }
      return !canMove;
    }

    return false;
  }

  // Switch to next player
  void switchPlayer() {
    currentPlayer = currentPlayer == 1 ? 2 : 1;
  }

  // Reset game
  void reset() {
    board = List.filled(24, null);
    currentPlayer = 1;
    phase = 'placing';
    piecesLeft = {1: 9, 2: 9};
    piecesOnBoard = {1: 0, 2: 0};
    selectedPosition = null;
    _history.clear();
    _redoStack.clear();
    _saveState(); // Save initial state
  }

  // Get status message
  String getStatusMessage() {
    if (checkWinCondition()) {
      return 'Lojtari $currentPlayer fitoi! 🎉';
    }

    String action = '';
    switch (phase) {
      case 'placing':
        action = 'Vendos figurën';
        break;
      case 'moving':
        action = selectedPosition == null
            ? 'Zgjidh figurën për ta lëvizur'
            : 'Zgjidh ku ta lëvizësh';
        break;
      case 'removing':
        action = 'Hiq figurën e kundërshtarit';
        break;
    }

    return 'Lojtari $currentPlayer: $action';
  }

  // Get valid moves for a position
  List<int> getValidMoves(int fromPos) {
    if (board[fromPos] != currentPlayer) return [];

    bool canFly = piecesOnBoard[currentPlayer]! == 3;

    if (canFly) {
      // Can move to any empty position
      return board
          .asMap()
          .entries
          .where((entry) => entry.value == null)
          .map((entry) => entry.key)
          .toList();
    } else {
      // Can only move to adjacent empty positions
      return (connections[fromPos] ?? [])
          .where((pos) => board[pos] == null)
          .toList();
    }
  }

  // Get removable pieces
  List<int> getRemovablePieces() {
    int opponent = currentPlayer == 1 ? 2 : 1;
    List<int> removable = [];
    bool hasNonMillPieces = false;

    for (int i = 0; i < 24; i++) {
      if (board[i] == opponent) {
        if (!checkMill(i)) {
          removable.add(i);
          hasNonMillPieces = true;
        }
      }
    }

    // If all pieces are in mills, can remove any
    if (!hasNonMillPieces) {
      for (int i = 0; i < 24; i++) {
        if (board[i] == opponent) {
          removable.add(i);
        }
      }
    }

    return removable;
  }

  // ============ AI LOGIC ============

  void makeAIMove() {
    if (phase == 'placing') {
      _aiPlacePiece();
    } else if (phase == 'moving') {
      _aiMovePiece();
    } else if (phase == 'removing') {
      _aiRemovePiece();
    }
  }

  void _aiPlacePiece() {
    List<int> emptyPositions = [];
    for (int i = 0; i < 24; i++) {
      if (board[i] == null) emptyPositions.add(i);
    }

    // 1. Try to complete a mill
    for (int pos in emptyPositions) {
      board[pos] = aiPlayer;
      if (checkMill(pos)) {
        board[pos] = null; // Reset
        placePiece(pos);
        return;
      }
      board[pos] = null;
    }

    // 2. Block opponent's mill
    int opponent = aiPlayer == 1 ? 2 : 1;
    for (int pos in emptyPositions) {
      board[pos] = opponent;
      if (checkMill(pos)) {
        board[pos] = null;
        placePiece(pos);
        return;
      }
      board[pos] = null;
    }

    // 3. Strategic positions (corners and centers)
    List<int> strategic = [1, 3, 5, 7, 9, 11, 13, 15];
    List<int> availableStrategic =
        emptyPositions.where((pos) => strategic.contains(pos)).toList();
    if (availableStrategic.isNotEmpty) {
      placePiece(availableStrategic[Random().nextInt(availableStrategic.length)]);
      return;
    }

    // 4. Random placement
    placePiece(emptyPositions[Random().nextInt(emptyPositions.length)]);
  }

  void _aiMovePiece() {
    List<int> aiPieces = [];
    for (int i = 0; i < 24; i++) {
      if (board[i] == aiPlayer) aiPieces.add(i);
    }

    // 1. Try to form a mill
    for (int from in aiPieces) {
      List<int> moves = getValidMoves(from);
      for (int to in moves) {
        int? temp = board[from];
        board[from] = null;
        board[to] = temp;
        if (checkMill(to)) {
          board[from] = temp;
          board[to] = null;
          movePiece(from, to);
          return;
        }
        board[from] = temp;
        board[to] = null;
      }
    }

    // 2. Block opponent
    int opponent = aiPlayer == 1 ? 2 : 1;
    for (int from in aiPieces) {
      List<int> moves = getValidMoves(from);
      for (int to in moves) {
        board[to] = opponent;
        if (checkMill(to)) {
          board[to] = null;
          movePiece(from, to);
          return;
        }
        board[to] = null;
      }
    }

    // 3. Random move
    int from = aiPieces[Random().nextInt(aiPieces.length)];
    List<int> moves = getValidMoves(from);
    if (moves.isNotEmpty) {
      movePiece(from, moves[Random().nextInt(moves.length)]);
    }
  }

  void _aiRemovePiece() {
    List<int> removable = getRemovablePieces();
    if (removable.isNotEmpty) {
      removePiece(removable[Random().nextInt(removable.length)]);
    }
  }
}

// Helper class for undo/redo functionality (renamed to avoid conflict with game_state.dart)
class GameSnapshot {
  final List<int?> board;
  final int currentPlayer;
  final String phase;
  final Map<int, int> piecesLeft;
  final Map<int, int> piecesOnBoard;

  GameSnapshot({
    required this.board,
    required this.currentPlayer,
    required this.phase,
    required this.piecesLeft,
    required this.piecesOnBoard,
  });
}
