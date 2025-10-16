import 'package:flutter/material.dart';

class GameState extends ChangeNotifier {
  // Game state variables
  List<int?> _board = List.filled(24, null);
  int _currentPlayer = 1;
  String _phase = 'placing'; // placing, moving, removing
  Map<int, int> _piecesLeft = {1: 9, 2: 9};
  Map<int, int> _piecesOnBoard = {1: 0, 2: 0};
  int? _selectedPosition;
  bool _isMyTurn = false;
  int? _myPlayerNumber;
  String? _winner;
  String _status = '';

  // Getters
  List<int?> get board => _board;
  int get currentPlayer => _currentPlayer;
  String get phase => _phase;
  Map<int, int> get piecesLeft => _piecesLeft;
  Map<int, int> get piecesOnBoard => _piecesOnBoard;
  int? get selectedPosition => _selectedPosition;
  bool get isMyTurn => _isMyTurn;
  int? get myPlayerNumber => _myPlayerNumber;
  String? get winner => _winner;
  String get status => _status;

  void setGameState(Map<String, dynamic> state) {
    _board = List<int?>.from(state['board']);
    _currentPlayer = state['currentPlayer'];
    _phase = state['phase'];
    _piecesLeft = Map<int, int>.from(state['piecesLeft']);
    _piecesOnBoard = Map<int, int>.from(state['piecesOnBoard']);
    _isMyTurn = state['isMyTurn'];
    _myPlayerNumber = state['myPlayerNumber'];
    _status = state['status'];
    _winner = state['winner'];
    notifyListeners();
  }

  void updateStatus(String newStatus) {
    _status = newStatus;
    notifyListeners();
  }
  
  void selectPosition(int? position) {
    _selectedPosition = position;
    notifyListeners();
  }

  void resetGame() {
    _board = List.filled(24, null);
    _currentPlayer = 1;
    _phase = 'placing';
    _piecesLeft = {1: 9, 2: 9};
    _piecesOnBoard = {1: 0, 2: 0};
    _selectedPosition = null;
    _isMyTurn = false;
    _myPlayerNumber = null;
    _winner = null;
    _status = '';
    notifyListeners();
  }
}
