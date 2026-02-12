import 'move_model.dart';

enum GameStatus { ongoing, whiteWins, blackWins, draw, resigned }

class GameModel {
  final String id;
  final String difficulty;
  final List<MoveModel> moves;
  final GameStatus status;
  final DateTime startedAt;
  final DateTime? endedAt;
  final bool playerIsWhite;

  GameModel({
    required this.id,
    required this.difficulty,
    this.moves = const [],
    this.status = GameStatus.ongoing,
    DateTime? startedAt,
    this.endedAt,
    this.playerIsWhite = true,
  }) : startedAt = startedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'difficulty': difficulty,
      'moves': moves.map((m) => m.toJson()).toList(),
      'status': status.index,
      'startedAt': startedAt.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'playerIsWhite': playerIsWhite,
    };
  }

  factory GameModel.fromJson(Map<String, dynamic> json) {
    return GameModel(
      id: json['id'] ?? '',
      difficulty: json['difficulty'] ?? 'Medium',
      moves: (json['moves'] as List<dynamic>?)
              ?.map((m) => MoveModel.fromJson(m))
              .toList() ??
          [],
      status: GameStatus.values[json['status'] ?? 0],
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'])
          : DateTime.now(),
      endedAt:
          json['endedAt'] != null ? DateTime.parse(json['endedAt']) : null,
      playerIsWhite: json['playerIsWhite'] ?? true,
    );
  }

  GameModel copyWith({
    String? id,
    String? difficulty,
    List<MoveModel>? moves,
    GameStatus? status,
    DateTime? startedAt,
    DateTime? endedAt,
    bool? playerIsWhite,
  }) {
    return GameModel(
      id: id ?? this.id,
      difficulty: difficulty ?? this.difficulty,
      moves: moves ?? this.moves,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      playerIsWhite: playerIsWhite ?? this.playerIsWhite,
    );
  }

  String get statusText {
    switch (status) {
      case GameStatus.ongoing:
        return 'Ongoing';
      case GameStatus.whiteWins:
        return 'White Wins';
      case GameStatus.blackWins:
        return 'Black Wins';
      case GameStatus.draw:
        return 'Draw';
      case GameStatus.resigned:
        return 'Resigned';
    }
  }
}
