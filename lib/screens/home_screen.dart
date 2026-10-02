import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../services/attendance_calculator.dart';
import '../utils/app_colors.dart';
import '../widgets/attendance_card.dart';
import '../widgets/custom_button.dart';

/// HomeScreen is the attractive main dashboard for the Attendance Predictor app.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final recentCalculations = AttendanceCalculator.sessionHistory;
    final hasHistory = recentCalculations.isNotEmpty;
    final latestRecord = hasHistory ? recentCalculations.first : null;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.school_rounded, color: AppColors.primary, size: 24),
            SizedBox(width: 8),
            Text('Attendance Predictor'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'View Calculation History',
            icon: const Icon(Icons.history_rounded),
            onPressed: () async {
              await Navigator.pushNamed(context, AppRoutes.history);
              setState(() {}); // Refresh upon returning
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome / Hero Banner Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Student Smart Tool',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Predict & Protect Your Attendance',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Check if you meet 75% or 80% criteria, see how many upcoming classes you can miss, and calculate how to recover.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Recent calculation preview card if available
              if (latestRecord != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Latest Calculation',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        await Navigator.pushNamed(context, AppRoutes.history);
                        setState(() {});
                      },
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                AttendanceCard(
                  title: 'Current Attendance (${latestRecord.formattedTargetPercentage} Target)',
                  value: latestRecord.formattedCurrentPercentage,
                  subtitle: latestRecord.isSafe
                      ? 'Safe zone • Can miss ${latestRecord.classesCanMiss} class(es)'
                      : 'Need improvement • Need ${latestRecord.classesNeeded} class(es)',
                  icon: latestRecord.isSafe
                      ? Icons.check_circle_rounded
                      : Icons.warning_amber_rounded,
                  iconColor: latestRecord.isSafe ? AppColors.safe : AppColors.warning,
                  backgroundColor: latestRecord.isSafe
                      ? AppColors.safeBackground
                      : AppColors.warningBackground,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.result,
                      arguments: latestRecord,
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],

              // Quick Info / Feature Cards
              const Text(
                'Key Features',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              const AttendanceCard(
                title: 'Real-time Calculation',
                value: 'Accurate Attendance %',
                subtitle: 'Computes exact percentage based on classes attended and total held.',
                icon: Icons.calculate_rounded,
                iconColor: AppColors.primary,
              ),
              const SizedBox(height: 12),

              const AttendanceCard(
                title: 'Future Forecast',
                value: 'Upcoming Classes Impact',
                subtitle: 'Simulates whether future attendance can pull you past target.',
                icon: Icons.trending_up_rounded,
                iconColor: AppColors.secondary,
              ),
              const SizedBox(height: 12),

              const AttendanceCard(
                title: 'Bunk & Recovery Helper',
                value: 'Safe Misses & Catch-up',
                subtitle: 'Know how many classes you can skip or must attend to be safe.',
                icon: Icons.health_and_safety_rounded,
                iconColor: AppColors.safe,
              ),
              const SizedBox(height: 28),

              // Action Buttons
              CustomButton(
                text: 'Calculate Attendance',
                icon: Icons.arrow_forward_rounded,
                onPressed: () async {
                  await Navigator.pushNamed(context, AppRoutes.input);
                  setState(() {}); // Refresh home screen with latest calculation
                },
              ),
              const SizedBox(height: 12),

              CustomButton(
                text: 'View History (${recentCalculations.length})',
                icon: Icons.history_rounded,
                isOutlined: true,
                onPressed: () async {
                  await Navigator.pushNamed(context, AppRoutes.history);
                  setState(() {});
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
