import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/game_model.dart';
import '../models/move_model.dart';
import '../services/game_service.dart';
import '../utils/chess_logic.dart';

class GameProvider extends ChangeNotifier {
  final GameService _gameService = GameService();
  final Uuid _uuid = const Uuid();

  GameModel? _currentGame;
  List<GameModel> _recentGames = [];
  List<List<String>> _board = [];
  List<int>? _selectedPiece;
  List<List<int>> _validMoves = [];
  bool _isWhiteTurn = true;
  bool _isLoading = false;
  String _gameStatus = '';
  int _whiteTime = 600;
  int _blackTime = 600;
  bool _isTimerRunning = false;

  GameModel? get currentGame => _currentGame;
  List<GameModel> get recentGames => _recentGames;
  List<List<String>> get board => _board;
  List<int>? get selectedPiece => _selectedPiece;
  List<List<int>> get validMoves => _validMoves;
  bool get isWhiteTurn => _isWhiteTurn;
  bool get isLoading => _isLoading;
  String get gameStatus => _gameStatus;
  int get whiteTime => _whiteTime;
  int get blackTime => _blackTime;
  bool get isTimerRunning => _isTimerRunning;

  Future<void> loadRecentGames() async {
    _isLoading = true;
    notifyListeners();

    _recentGames = await _gameService.getSavedGames();

    _isLoading = false;
    notifyListeners();
  }

  void startNewGame(String difficulty) {
    _currentGame = GameModel(
      id: _uuid.v4(),
      difficulty: difficulty,
    );
    _board = ChessLogic.getInitialBoard();
    _isWhiteTurn = true;
    _selectedPiece = null;
    _validMoves = [];
    _gameStatus = '';
    _whiteTime = 600;
    _blackTime = 600;
    _isTimerRunning = true;
    notifyListeners();
  }

  void selectPiece(int row, int col) {
    if (_currentGame == null || _currentGame!.status != GameStatus.ongoing) return;

    final piece = _board[row][col];
    
    if (piece.isEmpty) {
      if (_selectedPiece != null && _isValidMove(row, col)) {
        _makeMove(_selectedPiece![0], _selectedPiece![1], row, col);
      }
      return;
    }

    final isWhitePiece = piece == piece.toUpperCase();
    
    if (isWhitePiece == _isWhiteTurn) {
      _selectedPiece = [row, col];
      _validMoves = ChessLogic.getValidMoves(_board, row, col);
      notifyListeners();
    } else if (_selectedPiece != null && _isValidMove(row, col)) {
      _makeMove(_selectedPiece![0], _selectedPiece![1], row, col);
    }
  }

  bool _isValidMove(int row, int col) {
    return _validMoves.any((move) => move[0] == row && move[1] == col);
  }

  void _makeMove(int fromRow, int fromCol, int toRow, int toCol) {
    final piece = _board[fromRow][fromCol];
    final capturedPiece = _board[toRow][toCol];

    _board[toRow][toCol] = piece;
    _board[fromRow][fromCol] = '';

    final move = MoveModel(
      fromRow: fromRow,
      fromCol: fromCol,
      toRow: toRow,
      toCol: toCol,
      piece: piece,
      capturedPiece: capturedPiece.isNotEmpty ? capturedPiece : null,
    );

    _currentGame = _currentGame!.copyWith(
      moves: [..._currentGame!.moves, move],
    );

    _selectedPiece = null;
    _validMoves = [];
    _isWhiteTurn = !_isWhiteTurn;

    _checkGameStatus();
    notifyListeners();

    if (!_isWhiteTurn && _currentGame!.status == GameStatus.ongoing) {
      _makeAIMove();
    }
  }

  void _makeAIMove() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_currentGame == null || _currentGame!.status != GameStatus.ongoing) return;

      final aiMove = ChessLogic.getAIMove(_board, _currentGame!.difficulty);
      if (aiMove != null) {
        _makeMove(aiMove[0], aiMove[1], aiMove[2], aiMove[3]);
      }
    });
  }

  void _checkGameStatus() {
    final isInCheck = ChessLogic.isKingInCheck(_board, _isWhiteTurn);
    final hasValidMoves = ChessLogic.hasValidMoves(_board, _isWhiteTurn);

    if (isInCheck && !hasValidMoves) {
      _gameStatus = _isWhiteTurn ? 'Checkmate! Black wins!' : 'Checkmate! White wins!';
      _currentGame = _currentGame!.copyWith(
        status: _isWhiteTurn ? GameStatus.blackWins : GameStatus.whiteWins,
        endedAt: DateTime.now(),
      );
      _isTimerRunning = false;
      _saveCurrentGame();
    } else if (!hasValidMoves) {
      _gameStatus = 'Stalemate! Draw!';
      _currentGame = _currentGame!.copyWith(
        status: GameStatus.draw,
        endedAt: DateTime.now(),
      );
      _isTimerRunning = false;
      _saveCurrentGame();
    } else if (isInCheck) {
      _gameStatus = 'Check!';
    } else {
      _gameStatus = '';
    }
  }

  void undoMove() {
    if (_currentGame == null || _currentGame!.moves.length < 2) return;

    final moves = List<MoveModel>.from(_currentGame!.moves);
    moves.removeLast();
    moves.removeLast();

    _currentGame = _currentGame!.copyWith(moves: moves);
    _board = ChessLogic.getInitialBoard();
    
    for (final move in moves) {
      _board[move.toRow][move.toCol] = move.piece;
      _board[move.fromRow][move.fromCol] = '';
    }

    _isWhiteTurn = true;
    _selectedPiece = null;
    _validMoves = [];
    _gameStatus = '';
    notifyListeners();
  }

  void resignGame() {
    if (_currentGame == null) return;

    _currentGame = _currentGame!.copyWith(
      status: GameStatus.resigned,
      endedAt: DateTime.now(),
    );
    _gameStatus = 'You resigned. AI wins!';
    _isTimerRunning = false;
    _saveCurrentGame();
    notifyListeners();
  }

  void pauseGame() {
    _isTimerRunning = !_isTimerRunning;
    notifyListeners();
  }

  Future<void> _saveCurrentGame() async {
    if (_currentGame != null) {
      await _gameService.saveGame(_currentGame!);
      await loadRecentGames();
    }
  }

  Future<GameModel?> getGameForReplay(String gameId) async {
    return await _gameService.getGameById(gameId);
  }

  List<Map<String, dynamic>> getLeaderboard() {
    return _gameService.getLeaderboard();
  }

  void updateTimer() {
    if (!_isTimerRunning) return;
    
    if (_isWhiteTurn) {
      _whiteTime--;
      if (_whiteTime <= 0) {
        _gameStatus = 'Time out! Black wins!';
        _currentGame = _currentGame?.copyWith(
          status: GameStatus.blackWins,
          endedAt: DateTime.now(),
        );
        _isTimerRunning = false;
        _saveCurrentGame();
      }
    } else {
      _blackTime--;
      if (_blackTime <= 0) {
        _gameStatus = 'Time out! White wins!';
        _currentGame = _currentGame?.copyWith(
          status: GameStatus.whiteWins,
          endedAt: DateTime.now(),
        );
        _isTimerRunning = false;
        _saveCurrentGame();
      }
    }
    notifyListeners();
  }
}
