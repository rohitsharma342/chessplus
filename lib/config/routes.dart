import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/game_screen.dart';
import '../screens/game_replay_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/help_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String game = '/game';
  static const String gameReplay = '/game-replay';
  static const String settings = '/settings';
  static const String help = '/help';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _buildRoute(const SplashScreen());
      case login:
        return _buildRoute(const LoginScreen());
      case register:
        return _buildRoute(const RegisterScreen());
      case dashboard:
        return _buildRoute(const DashboardScreen());
      case game:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(GameScreen(
          difficulty: args?['difficulty'] ?? 'Medium',
        ));
      case gameReplay:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(GameReplayScreen(
          gameId: args?['gameId'] ?? '',
        ));
      case AppRoutes.settings:
        return _buildRoute(const SettingsScreen());
      case help:
        return _buildRoute(const HelpScreen());
      default:
        return _buildRoute(const SplashScreen());
    }
  }

  static PageRouteBuilder _buildRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
