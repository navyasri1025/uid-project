import 'package:flutter/material.dart';
import '../models/attendance_model.dart';
import '../screens/home_screen.dart';
import '../screens/attendance_input_screen.dart';
import '../screens/result_screen.dart';
import '../screens/history_screen.dart';

/// AppRoutes manages application named route constants and navigation mapping.
class AppRoutes {
  static const String home = '/';
  static const String input = '/input';
  static const String result = '/result';
  static const String history = '/history';

  /// Generates routes dynamically to allow passing typed arguments cleanly.
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return _buildPage(const HomeScreen(), settings);

      case input:
        return _buildPage(const AttendanceInputScreen(), settings);

      case result:
        final model = settings.arguments as AttendanceModel;
        return _buildPage(ResultScreen(attendance: model), settings);

      case history:
        return _buildPage(const HistoryScreen(), settings);

      default:
        return _buildPage(const HomeScreen(), settings);
    }
  }

  static PageRouteBuilder<dynamic> _buildPage(
      Widget page, RouteSettings settings) {
    return PageRouteBuilder<dynamic>(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionDuration: const Duration(milliseconds: 280),
      transitionsBuilder: (_, animation, __, child) {
        final curved =
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.025),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}
