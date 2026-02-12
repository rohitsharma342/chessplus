import 'dart:math';

class ChessLogic {
  static List<List<String>> getInitialBoard() {
    return [
      ['r', 'n', 'b', 'q', 'k', 'b', 'n', 'r'],
      ['p', 'p', 'p', 'p', 'p', 'p', 'p', 'p'],
      ['', '', '', '', '', '', '', ''],
      ['', '', '', '', '', '', '', ''],
      ['', '', '', '', '', '', '', ''],
      ['', '', '', '', '', '', '', ''],
      ['P', 'P', 'P', 'P', 'P', 'P', 'P', 'P'],
      ['R', 'N', 'B', 'Q', 'K', 'B', 'N', 'R'],
    ];
  }

  static List<List<int>> getValidMoves(
      List<List<String>> board, int row, int col) {
    if (board.isEmpty) return [];
    
    final piece = board[row][col];
    if (piece.isEmpty) return [];

    final isWhite = piece == piece.toUpperCase();
    List<List<int>> moves = [];

    switch (piece.toLowerCase()) {
      case 'p':
        moves = _getPawnMoves(board, row, col, isWhite);
        break;
      case 'r':
        moves = _getRookMoves(board, row, col, isWhite);
        break;
      case 'n':
        moves = _getKnightMoves(board, row, col, isWhite);
        break;
      case 'b':
        moves = _getBishopMoves(board, row, col, isWhite);
        break;
      case 'q':
        moves = _getQueenMoves(board, row, col, isWhite);
        break;
      case 'k':
        moves = _getKingMoves(board, row, col, isWhite);
        break;
    }

    return moves.where((move) {
      final testBoard = _copyBoard(board);
      testBoard[move[0]][move[1]] = testBoard[row][col];
      testBoard[row][col] = '';
      return !isKingInCheck(testBoard, isWhite);
    }).toList();
  }

  static List<List<int>> _getPawnMoves(
      List<List<String>> board, int row, int col, bool isWhite) {
    List<List<int>> moves = [];
    final direction = isWhite ? -1 : 1;
    final startRow = isWhite ? 6 : 1;

    if (_isValidSquare(row + direction, col) &&
        board[row + direction][col].isEmpty) {
      moves.add([row + direction, col]);

      if (row == startRow &&
          board[row + 2 * direction][col].isEmpty) {
        moves.add([row + 2 * direction, col]);
      }
    }

    for (final dc in [-1, 1]) {
      if (_isValidSquare(row + direction, col + dc)) {
        final target = board[row + direction][col + dc];
        if (target.isNotEmpty && _isOpponentPiece(target, isWhite)) {
          moves.add([row + direction, col + dc]);
        }
      }
    }

    return moves;
  }

  static List<List<int>> _getRookMoves(
      List<List<String>> board, int row, int col, bool isWhite) {
    return _getSlidingMoves(board, row, col, isWhite, [
      [0, 1],
      [0, -1],
      [1, 0],
      [-1, 0]
    ]);
  }

  static List<List<int>> _getBishopMoves(
      List<List<String>> board, int row, int col, bool isWhite) {
    return _getSlidingMoves(board, row, col, isWhite, [
      [1, 1],
      [1, -1],
      [-1, 1],
      [-1, -1]
    ]);
  }

  static List<List<int>> _getQueenMoves(
      List<List<String>> board, int row, int col, bool isWhite) {
    return _getSlidingMoves(board, row, col, isWhite, [
      [0, 1],
      [0, -1],
      [1, 0],
      [-1, 0],
      [1, 1],
      [1, -1],
      [-1, 1],
      [-1, -1]
    ]);
  }

  static List<List<int>> _getSlidingMoves(List<List<String>> board, int row,
      int col, bool isWhite, List<List<int>> directions) {
    List<List<int>> moves = [];

    for (final dir in directions) {
      int r = row + dir[0];
      int c = col + dir[1];

      while (_isValidSquare(r, c)) {
        final target = board[r][c];
        if (target.isEmpty) {
          moves.add([r, c]);
        } else if (_isOpponentPiece(target, isWhite)) {
          moves.add([r, c]);
          break;
        } else {
          break;
        }
        r += dir[0];
        c += dir[1];
      }
    }

    return moves;
  }

  static List<List<int>> _getKnightMoves(
      List<List<String>> board, int row, int col, bool isWhite) {
    List<List<int>> moves = [];
    final offsets = [
      [-2, -1],
      [-2, 1],
      [-1, -2],
      [-1, 2],
      [1, -2],
      [1, 2],
      [2, -1],
      [2, 1]
    ];

    for (final offset in offsets) {
      final r = row + offset[0];
      final c = col + offset[1];

      if (_isValidSquare(r, c)) {
        final target = board[r][c];
        if (target.isEmpty || _isOpponentPiece(target, isWhite)) {
          moves.add([r, c]);
        }
      }
    }

    return moves;
  }

  static List<List<int>> _getKingMoves(
      List<List<String>> board, int row, int col, bool isWhite) {
    List<List<int>> moves = [];

    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue;

        final r = row + dr;
        final c = col + dc;

        if (_isValidSquare(r, c)) {
          final target = board[r][c];
          if (target.isEmpty || _isOpponentPiece(target, isWhite)) {
            moves.add([r, c]);
          }
        }
      }
    }

    return moves;
  }

  static bool _isValidSquare(int row, int col) {
    return row >= 0 && row < 8 && col >= 0 && col < 8;
  }

  static bool _isOpponentPiece(String piece, bool isWhite) {
    if (piece.isEmpty) return false;
    final pieceIsWhite = piece == piece.toUpperCase();
    return pieceIsWhite != isWhite;
  }

  static bool isKingInCheck(List<List<String>> board, bool isWhite) {
    int kingRow = -1;
    int kingCol = -1;
    final kingPiece = isWhite ? 'K' : 'k';

    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        if (board[r][c] == kingPiece) {
          kingRow = r;
          kingCol = c;
          break;
        }
      }
      if (kingRow != -1) break;
    }

    if (kingRow == -1) return false;

    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final piece = board[r][c];
        if (piece.isNotEmpty && _isOpponentPiece(piece, isWhite)) {
          final moves = _getRawMoves(board, r, c, !isWhite);
          if (moves.any((m) => m[0] == kingRow && m[1] == kingCol)) {
            return true;
          }
        }
      }
    }

    return false;
  }

  static List<List<int>> _getRawMoves(
      List<List<String>> board, int row, int col, bool isWhite) {
    final piece = board[row][col];
    switch (piece.toLowerCase()) {
      case 'p':
        return _getPawnMoves(board, row, col, isWhite);
      case 'r':
        return _getRookMoves(board, row, col, isWhite);
      case 'n':
        return _getKnightMoves(board, row, col, isWhite);
      case 'b':
        return _getBishopMoves(board, row, col, isWhite);
      case 'q':
        return _getQueenMoves(board, row, col, isWhite);
      case 'k':
        return _getKingMoves(board, row, col, isWhite);
      default:
        return [];
    }
  }

  static bool hasValidMoves(List<List<String>> board, bool isWhite) {
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final piece = board[r][c];
        if (piece.isNotEmpty) {
          final pieceIsWhite = piece == piece.toUpperCase();
          if (pieceIsWhite == isWhite) {
            final moves = getValidMoves(board, r, c);
            if (moves.isNotEmpty) return true;
          }
        }
      }
    }
    return false;
  }

  static List<int>? getAIMove(List<List<String>> board, String difficulty) {
    final isWhite = false;
    List<List<int>> allMoves = [];

    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final piece = board[r][c];
        if (piece.isNotEmpty) {
          final pieceIsWhite = piece == piece.toUpperCase();
          if (pieceIsWhite == isWhite) {
            final moves = getValidMoves(board, r, c);
            for (final move in moves) {
              allMoves.add([r, c, move[0], move[1]]);
            }
          }
        }
      }
    }

    if (allMoves.isEmpty) return null;

    if (difficulty == 'Easy') {
      return allMoves[Random().nextInt(allMoves.length)];
    }

    List<int>? bestMove;
    int bestScore = -99999;

    for (final move in allMoves) {
      final testBoard = _copyBoard(board);
      final capturedPiece = testBoard[move[2]][move[3]];
      testBoard[move[2]][move[3]] = testBoard[move[0]][move[1]];
      testBoard[move[0]][move[1]] = '';

      int score = _evaluateBoard(testBoard, false);

      if (capturedPiece.isNotEmpty) {
        score += _getPieceValue(capturedPiece) * 10;
      }

      if (isKingInCheck(testBoard, true)) {
        score += 50;
      }

      if (difficulty == 'Medium') {
        score += Random().nextInt(20) - 10;
      }

      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }

    return bestMove ?? allMoves[Random().nextInt(allMoves.length)];
  }

  static int _evaluateBoard(List<List<String>> board, bool isWhite) {
    int score = 0;

    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final piece = board[r][c];
        if (piece.isNotEmpty) {
          final pieceIsWhite = piece == piece.toUpperCase();
          final value = _getPieceValue(piece);
          score += pieceIsWhite ? -value : value;
        }
      }
    }

    return score;
  }

  static int _getPieceValue(String piece) {
    switch (piece.toLowerCase()) {
      case 'p':
        return 100;
      case 'n':
        return 320;
      case 'b':
        return 330;
      case 'r':
        return 500;
      case 'q':
        return 900;
      case 'k':
        return 20000;
      default:
        return 0;
    }
  }

  static List<List<String>> _copyBoard(List<List<String>> board) {
    return board.map((row) => List<String>.from(row)).toList();
  }
}
