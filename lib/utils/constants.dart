class AppConstants {
  static const String appName = 'ChessPlus';
  static const String appTagline = 'Master Your Game';
  
  static const List<String> difficulties = ['Easy', 'Medium', 'Hard'];
  
  static const int defaultGameTime = 600;
  
  static const int easyDepth = 1;
  static const int mediumDepth = 2;
  static const int hardDepth = 3;
  
  static const Map<String, int> pieceValues = {
    'p': 100,
    'n': 320,
    'b': 330,
    'r': 500,
    'q': 900,
    'k': 20000,
  };
}
