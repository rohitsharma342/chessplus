import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../providers/game_provider.dart';
import '../models/game_model.dart';
import '../models/move_model.dart';
import '../widgets/chess_board.dart';
import '../utils/chess_logic.dart';

class GameReplayScreen extends StatefulWidget {
  final String gameId;

  const GameReplayScreen({super.key, required this.gameId});

  @override
  State<GameReplayScreen> createState() => _GameReplayScreenState();
}

class _GameReplayScreenState extends State<GameReplayScreen> {
  GameModel? _game;
  List<List<String>> _board = [];
  int _currentMoveIndex = -1;
  bool _isPlaying = false;
  Timer? _playTimer;

  @override
  void initState() {
    super.initState();
    _loadGame();
  }

  Future<void> _loadGame() async {
    final game = await context.read<GameProvider>().getGameForReplay(widget.gameId);
    if (game != null) {
      setState(() {
        _game = game;
        _board = ChessLogic.getInitialBoard();
      });
    }
  }

  @override
  void dispose() {
    _playTimer?.cancel();
    super.dispose();
  }

  void _goToMove(int index) {
    if (_game == null) return;
    
    setState(() {
      _board = ChessLogic.getInitialBoard();
      _currentMoveIndex = -1;
    });

    for (int i = 0; i <= index && i < _game!.moves.length; i++) {
      final move = _game!.moves[i];
      setState(() {
        _board[move.toRow][move.toCol] = move.piece;
        _board[move.fromRow][move.fromCol] = '';
        _currentMoveIndex = i;
      });
    }
  }

  void _nextMove() {
    if (_game == null || _currentMoveIndex >= _game!.moves.length - 1) {
      _stopPlaying();
      return;
    }
    _goToMove(_currentMoveIndex + 1);
  }

  void _previousMove() {
    if (_currentMoveIndex < 0) return;
    _goToMove(_currentMoveIndex - 1);
  }

  void _togglePlay() {
    if (_isPlaying) {
      _stopPlaying();
    } else {
      _startPlaying();
    }
  }

  void _startPlaying() {
    if (_game == null) return;
    setState(() {
      _isPlaying = true;
    });
    _playTimer = Timer.periodic(const Duration(milliseconds: 1000), (_) {
      _nextMove();
    });
  }

  void _stopPlaying() {
    _playTimer?.cancel();
    setState(() {
      _isPlaying = false;
    });
  }

  void _reset() {
    _stopPlaying();
    setState(() {
      _board = ChessLogic.getInitialBoard();
      _currentMoveIndex = -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final boardSize = screenWidth > 600 ? 400.0 : screenWidth - 32;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
          },
        ),
        title: Text(
          'Game Replay',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: _game == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.cardColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _game!.difficulty,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _game!.status == GameStatus.whiteWins
                                ? AppTheme.successColor.withOpacity(0.2)
                                : _game!.status == GameStatus.blackWins
                                    ? AppTheme.errorColor.withOpacity(0.2)
                                    : AppTheme.cardColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _game!.statusText,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: _game!.status == GameStatus.whiteWins
                                      ? AppTheme.successColor
                                      : _game!.status == GameStatus.blackWins
                                          ? AppTheme.errorColor
                                          : null,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: ChessBoard(
                        board: _board,
                        selectedPiece: null,
                        validMoves: const [],
                        onSquareTap: (_, __) {},
                        size: boardSize,
                      ).animate().fadeIn(duration: 400.ms),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Move ${_currentMoveIndex + 1} of ${_game!.moves.length}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              onPressed: _reset,
                              icon: const Icon(Icons.replay),
                              style: IconButton.styleFrom(
                                backgroundColor: AppTheme.surfaceColor,
                                padding: const EdgeInsets.all(12),
                              ),
                            ),
                            IconButton(
                              onPressed: _currentMoveIndex >= 0 ? _previousMove : null,
                              icon: const Icon(Icons.skip_previous),
                              style: IconButton.styleFrom(
                                backgroundColor: AppTheme.surfaceColor,
                                padding: const EdgeInsets.all(12),
                              ),
                            ),
                            IconButton(
                              onPressed: _togglePlay,
                              icon: Icon(
                                _isPlaying ? Icons.pause : Icons.play_arrow,
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.all(16),
                              ),
                            ),
                            IconButton(
                              onPressed: _currentMoveIndex < _game!.moves.length - 1
                                  ? _nextMove
                                  : null,
                              icon: const Icon(Icons.skip_next),
                              style: IconButton.styleFrom(
                                backgroundColor: AppTheme.surfaceColor,
                                padding: const EdgeInsets.all(12),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                _goToMove(_game!.moves.length - 1);
                              },
                              icon: const Icon(Icons.last_page),
                              style: IconButton.styleFrom(
                                backgroundColor: AppTheme.surfaceColor,
                                padding: const EdgeInsets.all(12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (_game!.moves.isNotEmpty)
                    Container(
                      height: 80,
                      margin: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 16,
                      ),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _game!.moves.length,
                        itemBuilder: (context, index) {
                          final move = _game!.moves[index];
                          final isCurrentMove = index == _currentMoveIndex;
                          return GestureDetector(
                            onTap: () => _goToMove(index),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isCurrentMove
                                    ? AppTheme.primaryColor
                                    : AppTheme.surfaceColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: isCurrentMove
                                          ? Colors.white
                                          : AppTheme.textSecondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    move.notation,
                                    style: TextStyle(
                                      color: isCurrentMove
                                          ? Colors.white
                                          : AppTheme.textPrimary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
