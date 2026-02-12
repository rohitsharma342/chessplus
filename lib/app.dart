import 'package:flutter/material.dart';
import 'config/theme.dart';
import 'config/routes.dart';

class ChessPlusApp extends StatelessWidget {
  const ChessPlusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChessPlus',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
