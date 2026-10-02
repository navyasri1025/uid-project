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
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );

      case input:
        return MaterialPageRoute(
          builder: (_) => const AttendanceInputScreen(),
          settings: settings,
        );

      case result:
        final model = settings.arguments as AttendanceModel;
        return MaterialPageRoute(
          builder: (_) => ResultScreen(attendance: model),
          settings: settings,
        );

      case history:
        return MaterialPageRoute(
          builder: (_) => const HistoryScreen(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );
    }
  }
}

