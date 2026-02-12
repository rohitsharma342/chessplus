class MoveModel {
  final int fromRow;
  final int fromCol;
  final int toRow;
  final int toCol;
  final String piece;
  final String? capturedPiece;
  final bool isCheck;
  final bool isCheckmate;
  final DateTime timestamp;

  MoveModel({
    required this.fromRow,
    required this.fromCol,
    required this.toRow,
    required this.toCol,
    required this.piece,
    this.capturedPiece,
    this.isCheck = false,
    this.isCheckmate = false,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'fromRow': fromRow,
      'fromCol': fromCol,
      'toRow': toRow,
      'toCol': toCol,
      'piece': piece,
      'capturedPiece': capturedPiece,
      'isCheck': isCheck,
      'isCheckmate': isCheckmate,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory MoveModel.fromJson(Map<String, dynamic> json) {
    return MoveModel(
      fromRow: json['fromRow'] ?? 0,
      fromCol: json['fromCol'] ?? 0,
      toRow: json['toRow'] ?? 0,
      toCol: json['toCol'] ?? 0,
      piece: json['piece'] ?? '',
      capturedPiece: json['capturedPiece'],
      isCheck: json['isCheck'] ?? false,
      isCheckmate: json['isCheckmate'] ?? false,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  String get notation {
    String cols = 'abcdefgh';
    String fromNotation = '${cols[fromCol]}${8 - fromRow}';
    String toNotation = '${cols[toCol]}${8 - toRow}';
    return '$piece$fromNotation-$toNotation';
  }
}
