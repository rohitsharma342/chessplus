import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../providers/auth_provider.dart';
import '../providers/game_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/game_card.dart';
import '../widgets/leaderboard_item.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedDifficulty = 'Medium';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameProvider>().loadRecentGames();
      final settings = context.read<SettingsProvider>();
      setState(() {
        _selectedDifficulty = settings.defaultDifficulty;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _startNewGame() {
    Navigator.pushNamed(
      context,
      AppRoutes.game,
      arguments: {'difficulty': _selectedDifficulty},
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final gameProvider = context.watch<GameProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              backgroundColor: AppTheme.backgroundColor,
              automaticallyImplyLeading: false,
              title: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.castle_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'ChessPlus',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              actions: [
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () {
                        settingsProvider.clearNotifications();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('No new notifications'),
                          ),
                        );
                      },
                    ),
                    if (settingsProvider.notificationCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppTheme.errorColor,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${settingsProvider.notificationCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.settings);
                  },
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor,
                            AppTheme.primaryColor.withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hello, ${user?.username ?? 'Player'}!',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(color: Colors.white),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Ready for a challenge?',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${user?.rating ?? 1200}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _StatItem(
                                label: 'Played',
                                value: '${user?.gamesPlayed ?? 0}',
                              ),
                              const SizedBox(width: 24),
                              _StatItem(
                                label: 'Won',
                                value: '${user?.gamesWon ?? 0}',
                              ),
                              const SizedBox(width: 24),
                              _StatItem(
                                label: 'Lost',
                                value: '${user?.gamesLost ?? 0}',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Start New Game',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Select Difficulty',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedDifficulty,
                                isExpanded: true,
                                dropdownColor: AppTheme.surfaceColor,
                                items: ['Easy', 'Medium', 'Hard']
                                    .map((difficulty) => DropdownMenuItem(
                                          value: difficulty,
                                          child: Text(difficulty),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedDifficulty = value;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _startNewGame,
                              icon: const Icon(Icons.play_arrow_rounded),
                              label: const Text('Play Now'),
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 200.ms)
                        .slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search tutorials or help...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.help_outline),
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.help);
                          },
                        ),
                      ),
                      onSubmitted: (_) {
                        Navigator.pushNamed(context, AppRoutes.help);
                      },
                    )
                        .animate()
                        .fadeIn(delay: 300.ms)
                        .slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Games',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'View All',
                            style: TextStyle(color: AppTheme.primaryColor),
                          ),
                        ),
                      ],
                    )
                        .animate()
                        .fadeIn(delay: 400.ms)
                        .slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 12),
                    if (gameProvider.isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (gameProvider.recentGames.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.sports_esports_outlined,
                              size: 48,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No games yet',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Start a new game to see your history here',
                              style: Theme.of(context).textTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else
                      ...gameProvider.recentGames.take(3).map(
                            (game) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: GameCard(
                                game: game,
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.gameReplay,
                                    arguments: {'gameId': game.id},
                                  );
                                },
                              ),
                            )
                                .animate()
                                .fadeIn(
                                  delay: Duration(
                                    milliseconds: 500 +
                                        gameProvider.recentGames
                                                .indexOf(game) *
                                            100,
                                  ),
                                )
                                .slideX(begin: 0.1, end: 0),
                          ),
                    const SizedBox(height: 24),
                    Text(
                      'Leaderboard',
                      style: Theme.of(context).textTheme.titleLarge,
                    )
                        .animate()
                        .fadeIn(delay: 600.ms)
                        .slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: gameProvider
                            .getLeaderboard()
                            .take(5)
                            .map(
                              (player) => LeaderboardItem(
                                rank: player['rank'],
                                username: player['username'],
                                rating: player['rating'],
                                wins: player['wins'],
                              ),
                            )
                            .toList(),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 700.ms)
                        .slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
        ),
      ],
    );
  }
}
