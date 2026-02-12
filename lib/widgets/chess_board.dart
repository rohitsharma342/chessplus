import 'package:flutter/material.dart';
import '../config/theme.dart';
import 'chess_piece.dart';

class ChessBoard extends StatelessWidget {
  final List<List<String>> board;
  final List<int>? selectedPiece;
  final List<List<int>> validMoves;
  final Function(int row, int col) onSquareTap;
  final double size;

  const ChessBoard({
    super.key,
    required this.board,
    required this.selectedPiece,
    required this.validMoves,
    required this.onSquareTap,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final squareSize = size / 8;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Column(
          children: List.generate(8, (row) {
            return Row(
              children: List.generate(8, (col) {
                final isLightSquare = (row + col) % 2 == 0;
                final isSelected = selectedPiece != null &&
                    selectedPiece![0] == row &&
                    selectedPiece![1] == col;
                final isValidMove =
                    validMoves.any((move) => move[0] == row && move[1] == col);
                final piece = board.isNotEmpty ? board[row][col] : '';
                final isCapture = isValidMove && piece.isNotEmpty;

                return GestureDetector(
                  onTap: () => onSquareTap(row, col),
                  child: Container(
                    width: squareSize,
                    height: squareSize,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryColor.withOpacity(0.6)
                          : isLightSquare
                              ? const Color(0xFFEEEED2)
                              : const Color(0xFF769656),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (col == 0)
                          Positioned(
                            left: 2,
                            top: 2,
                            child: Text(
                              '${8 - row}',
                              style: TextStyle(
                                color: isLightSquare
                                    ? const Color(0xFF769656)
                                    : const Color(0xFFEEEED2),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (row == 7)
                          Positioned(
                            right: 2,
                            bottom: 2,
                            child: Text(
                              String.fromCharCode(97 + col),
                              style: TextStyle(
                                color: isLightSquare
                                    ? const Color(0xFF769656)
                                    : const Color(0xFFEEEED2),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (piece.isNotEmpty)
                          ChessPiece(
                            piece: piece,
                            size: squareSize * 0.8,
                          ),
                        if (isValidMove && !isCapture)
                          Container(
                            width: squareSize * 0.3,
                            height: squareSize * 0.3,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                          ),
                        if (isCapture)
                          Container(
                            width: squareSize * 0.9,
                            height: squareSize * 0.9,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black.withOpacity(0.2),
                                width: squareSize * 0.1,
                              ),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            );
          }),
        ),
      ),
    );
  }
}
