import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../providers/game_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/chess_board.dart';
import '../models/game_model.dart';

class GameScreen extends StatefulWidget {
  final String difficulty;

  const GameScreen({super.key, required this.difficulty});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameProvider>().startNewGame(widget.difficulty);
      _startTimer();
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      context.read<GameProvider>().updateTimer();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _showResignDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text('Resign Game?'),
        content: const Text('Are you sure you want to resign? This will count as a loss.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<GameProvider>().resignGame();
              context.read<AuthProvider>().updateUserStats(
                    won: false,
                    ratingChange: -15,
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Resign'),
          ),
        ],
      ),
    );
  }

  void _handleGameEnd(GameProvider gameProvider) {
    if (gameProvider.currentGame?.status == GameStatus.whiteWins) {
      context.read<AuthProvider>().updateUserStats(
            won: true,
            ratingChange: 25,
          );
    } else if (gameProvider.currentGame?.status == GameStatus.blackWins ||
        gameProvider.currentGame?.status == GameStatus.resigned) {
      context.read<AuthProvider>().updateUserStats(
            won: false,
            ratingChange: -15,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final boardSize = screenWidth > 600 ? 500.0 : screenWidth - 32;

    if (gameProvider.currentGame?.status != GameStatus.ongoing &&
        gameProvider.currentGame?.status != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleGameEnd(gameProvider);
      });
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            if (gameProvider.currentGame?.status == GameStatus.ongoing) {
              _showResignDialog();
            } else {
              Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
            }
          },
        ),
        title: Text(
          'vs AI (${widget.difficulty})',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          IconButton(
            icon: Icon(
              gameProvider.isTimerRunning
                  ? Icons.pause_circle_outline
                  : Icons.play_circle_outline,
            ),
            onPressed: () => gameProvider.pauseGame(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _PlayerInfo(
                    name: 'AI',
                    isActive: !gameProvider.isWhiteTurn,
                    time: _formatTime(gameProvider.blackTime),
                    isWhite: false,
                  ),
                  if (gameProvider.gameStatus.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: gameProvider.gameStatus.contains('Checkmate')
                            ? AppTheme.primaryColor
                            : gameProvider.gameStatus.contains('Check')
                                ? AppTheme.errorColor
                                : AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        gameProvider.gameStatus,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ).animate().scale(duration: 200.ms),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: ChessBoard(
                  board: gameProvider.board,
                  selectedPiece: gameProvider.selectedPiece,
                  validMoves: gameProvider.validMoves,
                  onSquareTap: (row, col) {
                    if (gameProvider.currentGame?.status == GameStatus.ongoing) {
                      gameProvider.selectPiece(row, col);
                    }
                  },
                  size: boardSize,
                ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _PlayerInfo(
                    name: 'You',
                    isActive: gameProvider.isWhiteTurn,
                    time: _formatTime(gameProvider.whiteTime),
                    isWhite: true,
                  ),
                  Row(
                    children: [
                      Text(
                        'Moves: ${gameProvider.currentGame?.moves.length ?? 0}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ActionButton(
                    icon: Icons.undo,
                    label: 'Undo',
                    onPressed: gameProvider.currentGame?.status ==
                            GameStatus.ongoing
                        ? () => gameProvider.undoMove()
                        : null,
                  ),
                  _ActionButton(
                    icon: Icons.flag_outlined,
                    label: 'Resign',
                    onPressed: gameProvider.currentGame?.status ==
                            GameStatus.ongoing
                        ? _showResignDialog
                        : null,
                    color: AppTheme.errorColor,
                  ),
                  if (gameProvider.currentGame?.status != GameStatus.ongoing)
                    _ActionButton(
                      icon: Icons.home,
                      label: 'Home',
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.dashboard,
                        );
                      },
                    ),
                  if (gameProvider.currentGame?.status != GameStatus.ongoing)
                    _ActionButton(
                      icon: Icons.refresh,
                      label: 'New Game',
                      onPressed: () {
                        gameProvider.startNewGame(widget.difficulty);
                      },
                      color: AppTheme.primaryColor,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerInfo extends StatelessWidget {
  final String name;
  final bool isActive;
  final String time;
  final bool isWhite;

  const _PlayerInfo({
    required this.name,
    required this.isActive,
    required this.time,
    required this.isWhite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primaryColor.withOpacity(0.2) : AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: isActive
            ? Border.all(color: AppTheme.primaryColor, width: 2)
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isWhite ? Colors.white : Colors.black,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.textSecondary,
                width: 1,
              ),
            ),
            child: Icon(
              Icons.person,
              color: isWhite ? Colors.black : Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                time,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                      color: isActive ? AppTheme.primaryColor : null,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color? color;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon),
          style: IconButton.styleFrom(
            backgroundColor: color?.withOpacity(0.2) ?? AppTheme.cardColor,
            foregroundColor: onPressed == null
                ? AppTheme.textSecondary
                : color ?? AppTheme.textPrimary,
            padding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: onPressed == null ? AppTheme.textSecondary : null,
              ),
        ),
      ],
    );
  }
}
