import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/theme.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, String>> _getFilteredContent(List<Map<String, String>> content) {
    if (_searchQuery.isEmpty) return content;
    return content.where((item) {
      return item['title']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item['content']!.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Help & Tutorial',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search help topics...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ).animate().fadeIn(delay: 100.ms),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: AppTheme.textSecondary,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Rules'),
                Tab(text: 'Tips'),
                Tab(text: 'How To'),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRulesTab(),
                _buildTipsTab(),
                _buildHowToTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRulesTab() {
    final rules = [
      {
        'title': 'The Objective',
        'content':
            'The goal of chess is to checkmate your opponent\'s king. This means the king is in a position to be captured (in "check") and there is no way to move the king out of capture.',
      },
      {
        'title': 'The Board',
        'content':
            'Chess is played on an 8x8 board with 64 squares alternating between light and dark colors. Each player starts with 16 pieces: one king, one queen, two rooks, two knights, two bishops, and eight pawns.',
      },
      {
        'title': 'How Pieces Move',
        'content':
            '• King: One square in any direction\n• Queen: Any number of squares in any direction\n• Rook: Any number of squares horizontally or vertically\n• Bishop: Any number of squares diagonally\n• Knight: "L" shape - two squares in one direction and one square perpendicular\n• Pawn: One square forward (two squares on first move), captures diagonally',
      },
      {
        'title': 'Check and Checkmate',
        'content':
            'When a king is threatened with capture, it is in "check". The player must move out of check immediately. If there is no legal move to escape, it is "checkmate" and the game is over.',
      },
      {
        'title': 'Special Moves',
        'content':
            '• Castling: A special move involving the king and a rook\n• En Passant: A special pawn capture\n• Pawn Promotion: When a pawn reaches the opposite end, it can become any piece except a king',
      },
    ];

    return _buildContentList(_getFilteredContent(rules));
  }

  Widget _buildTipsTab() {
    final tips = [
      {
        'title': 'Control the Center',
        'content':
            'The four central squares (e4, d4, e5, d5) are the most important squares on the board. Controlling them gives your pieces more mobility and options.',
      },
      {
        'title': 'Develop Your Pieces',
        'content':
            'In the opening, focus on developing your knights and bishops before your queen. Try to castle early to protect your king.',
      },
      {
        'title': 'Protect Your King',
        'content':
            'Always be aware of your king\'s safety. Castle early, keep pawns in front of your king, and don\'t leave your king exposed.',
      },
      {
        'title': 'Think Ahead',
        'content':
            'Try to think at least two to three moves ahead. Consider what your opponent might do in response to your moves.',
      },
      {
        'title': 'Learn Basic Tactics',
        'content':
            '• Forks: Attacking two pieces at once\n• Pins: Preventing a piece from moving because it would expose a more valuable piece\n• Skewers: Attacking a valuable piece that must move, exposing a piece behind it',
      },
      {
        'title': 'Don\'t Move the Same Piece Twice',
        'content':
            'In the opening, avoid moving the same piece multiple times unless necessary. Each move should develop a new piece or serve a clear purpose.',
      },
    ];

    return _buildContentList(_getFilteredContent(tips));
  }

  Widget _buildHowToTab() {
    final howTo = [
      {
        'title': 'Starting a New Game',
        'content':
            '1. From the Dashboard, select your preferred difficulty level\n2. Tap the "Play Now" button\n3. You will always play as White and move first\n4. Tap a piece to select it, then tap a highlighted square to move',
      },
      {
        'title': 'Making Moves',
        'content':
            '1. Tap on one of your pieces to select it\n2. Valid moves will be highlighted on the board\n3. Tap a highlighted square to move your piece there\n4. If you change your mind, tap another piece or the same piece to deselect',
      },
      {
        'title': 'Using Game Controls',
        'content':
            '• Undo: Take back your last move (and AI\'s response)\n• Resign: Give up the current game\n• Pause: Pause the game timer\n• The timer shows remaining time for each player',
      },
      {
        'title': 'Reviewing Past Games',
        'content':
            '1. From the Dashboard, find "Recent Games" section\n2. Tap on any completed game to review it\n3. Use the playback controls to step through moves\n4. Tap on any move in the list to jump to that position',
      },
      {
        'title': 'Changing Settings',
        'content':
            '1. Tap the Settings icon on the Dashboard\n2. Toggle sound effects on or off\n3. Set your default difficulty level\n4. Enable or disable notifications\n5. Access help and tutorials from here',
      },
    ];

    return _buildContentList(_getFilteredContent(howTo));
  }

  Widget _buildContentList(List<Map<String, String>> content) {
    if (content.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search term',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: content.length,
      itemBuilder: (context, index) {
        final item = content[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: ExpansionTile(
            title: Text(
              item['title']!,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            iconColor: AppTheme.primaryColor,
            collapsedIconColor: AppTheme.textSecondary,
            childrenPadding: const EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 16,
            ),
            children: [
              Text(
                item['content']!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                    ),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(delay: Duration(milliseconds: 100 + index * 50))
            .slideY(begin: 0.1, end: 0);
      },
    );
  }
}
