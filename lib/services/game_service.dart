import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_model.dart';
import '../models/move_model.dart';

class GameService {
  static const String _gamesKey = 'saved_games';

  Future<List<GameModel>> getSavedGames() async {
    final prefs = await SharedPreferences.getInstance();
    final gamesJson = prefs.getString(_gamesKey);
    
    if (gamesJson != null) {
      final gamesList = jsonDecode(gamesJson) as List<dynamic>;
      return gamesList.map((g) => GameModel.fromJson(g)).toList();
    }
    
    return _getMockGames();
  }

  Future<void> saveGame(GameModel game) async {
    final prefs = await SharedPreferences.getInstance();
    final games = await getSavedGames();
    
    final existingIndex = games.indexWhere((g) => g.id == game.id);
    if (existingIndex >= 0) {
      games[existingIndex] = game;
    } else {
      games.insert(0, game);
    }
    
    await prefs.setString(
      _gamesKey,
      jsonEncode(games.map((g) => g.toJson()).toList()),
    );
  }

  Future<GameModel?> getGameById(String id) async {
    final games = await getSavedGames();
    try {
      return games.firstWhere((g) => g.id == id);
    } catch (e) {
      return null;
    }
  }

  List<GameModel> _getMockGames() {
    return [
      GameModel(
        id: 'game_001',
        difficulty: 'Medium',
        status: GameStatus.whiteWins,
        startedAt: DateTime.now().subtract(const Duration(hours: 2)),
        endedAt: DateTime.now().subtract(const Duration(hours: 1)),
        moves: [
          MoveModel(fromRow: 6, fromCol: 4, toRow: 4, toCol: 4, piece: 'P'),
          MoveModel(fromRow: 1, fromCol: 4, toRow: 3, toCol: 4, piece: 'p'),
          MoveModel(fromRow: 7, fromCol: 6, toRow: 5, toCol: 5, piece: 'N'),
          MoveModel(fromRow: 0, fromCol: 1, toRow: 2, toCol: 2, piece: 'n'),
        ],
      ),
      GameModel(
        id: 'game_002',
        difficulty: 'Easy',
        status: GameStatus.blackWins,
        startedAt: DateTime.now().subtract(const Duration(days: 1)),
        endedAt: DateTime.now().subtract(const Duration(days: 1, hours: 23)),
        moves: [
          MoveModel(fromRow: 6, fromCol: 3, toRow: 4, toCol: 3, piece: 'P'),
          MoveModel(fromRow: 1, fromCol: 3, toRow: 3, toCol: 3, piece: 'p'),
        ],
      ),
      GameModel(
        id: 'game_003',
        difficulty: 'Hard',
        status: GameStatus.draw,
        startedAt: DateTime.now().subtract(const Duration(days: 2)),
        endedAt: DateTime.now().subtract(const Duration(days: 2, hours: 22)),
        moves: [],
      ),
    ];
  }

  List<Map<String, dynamic>> getLeaderboard() {
    return [
      {'rank': 1, 'username': 'GrandMaster99', 'rating': 2100, 'wins': 156},
      {'rank': 2, 'username': 'ChessKing', 'rating': 1980, 'wins': 142},
      {'rank': 3, 'username': 'QueenSlayer', 'rating': 1875, 'wins': 128},
      {'rank': 4, 'username': 'KnightRider', 'rating': 1750, 'wins': 115},
      {'rank': 5, 'username': 'BishopMaster', 'rating': 1680, 'wins': 98},
      {'rank': 6, 'username': 'RookDestroyer', 'rating': 1620, 'wins': 87},
      {'rank': 7, 'username': 'PawnPusher', 'rating': 1550, 'wins': 76},
      {'rank': 8, 'username': 'CheckMate101', 'rating': 1480, 'wins': 65},
      {'rank': 9, 'username': 'ChessMaster', 'rating': 1450, 'wins': 28},
      {'rank': 10, 'username': 'Strategist', 'rating': 1400, 'wins': 54},
    ];
  }
}
