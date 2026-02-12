import 'package:flutter/material.dart';

class ChessPiece extends StatelessWidget {
  final String piece;
  final double size;

  const ChessPiece({
    super.key,
    required this.piece,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final isWhite = piece == piece.toUpperCase();
    final pieceType = piece.toLowerCase();

    return Text(
      _getPieceSymbol(pieceType),
      style: TextStyle(
        fontSize: size,
        color: isWhite ? Colors.white : Colors.black,
        shadows: [
          Shadow(
            color: isWhite ? Colors.black : Colors.white,
            blurRadius: 2,
          ),
        ],
      ),
    );
  }

  String _getPieceSymbol(String pieceType) {
    switch (pieceType) {
      case 'k':
        return '♚';
      case 'q':
        return '♛';
      case 'r':
        return '♜';
      case 'b':
        return '♝';
      case 'n':
        return '♞';
      case 'p':
        return '♟';
      default:
        return '';
    }
  }
}
