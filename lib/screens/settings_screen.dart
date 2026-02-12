import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.username ?? 'Player',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? '',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Rating: ${user?.rating ?? 1200}',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: 24),
            Text(
              'Preferences',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 12),
            _SettingsTile(
              icon: Icons.volume_up_outlined,
              title: 'Sound Effects',
              subtitle: 'Enable game sounds',
              trailing: Switch(
                value: settingsProvider.soundEnabled,
                onChanged: (value) => settingsProvider.setSoundEnabled(value),
                activeColor: AppTheme.primaryColor,
              ),
            ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1, end: 0),
            _SettingsTile(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: 'Enable push notifications',
              trailing: Switch(
                value: settingsProvider.notificationsEnabled,
                onChanged: (value) =>
                    settingsProvider.setNotificationsEnabled(value),
                activeColor: AppTheme.primaryColor,
              ),
            ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1, end: 0),
            _SettingsTile(
              icon: Icons.speed_outlined,
              title: 'Default Difficulty',
              subtitle: 'Set default AI difficulty for new games',
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: settingsProvider.defaultDifficulty,
                    dropdownColor: AppTheme.surfaceColor,
                    items: ['Easy', 'Medium', 'Hard']
                        .map((difficulty) => DropdownMenuItem(
                              value: difficulty,
                              child: Text(difficulty),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        settingsProvider.setDefaultDifficulty(value);
                      }
                    },
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.1, end: 0),
            const SizedBox(height: 24),
            Text(
              'More',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ).animate().fadeIn(delay: 600.ms),
            const SizedBox(height: 12),
            _SettingsTile(
              icon: Icons.help_outline,
              title: 'Help & Tutorial',
              subtitle: 'Learn how to play chess',
              onTap: () => Navigator.pushNamed(context, AppRoutes.help),
            ).animate().fadeIn(delay: 700.ms).slideX(begin: -0.1, end: 0),
            _SettingsTile(
              icon: Icons.info_outline,
              title: 'About',
              subtitle: 'Version 1.0.0',
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'ChessPlus',
                  applicationVersion: '1.0.0',
                  applicationIcon: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.castle_rounded,
                      color: Colors.white,
                    ),
                  ),
                  children: [
                    const Text(
                      'ChessPlus is an engaging mobile game app designed to offer users a seamless and enjoyable chess-playing experience against AI.',
                    ),
                  ],
                );
              },
            ).animate().fadeIn(delay: 800.ms).slideX(begin: -0.1, end: 0),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await authProvider.logout();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.login,
                      (route) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Log Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 8,
        ),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.primaryColor),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: trailing ?? const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
