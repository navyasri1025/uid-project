import 'package:flutter/material.dart';
import '../models/attendance_model.dart';
import '../routes/app_routes.dart';
import '../utils/app_colors.dart';
import '../widgets/attendance_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/prediction_result.dart';

/// ResultScreen presents the attendance analysis and prediction results
/// clearly with visual percentage indicators, stats cards, and action buttons.
class ResultScreen extends StatelessWidget {
  final AttendanceModel attendance;

  const ResultScreen({
    super.key,
    required this.attendance,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Prediction'),
        actions: [
          IconButton(
            tooltip: 'View History',
            icon: const Icon(Icons.history_rounded),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.history);
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
              // Main visual results widget
              PredictionResult(attendance: attendance),
              const SizedBox(height: 20),

              // Statistics Breakdown Section
              const Text(
                'Class Breakdown',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: AttendanceCard(
                      title: 'Total Conducted',
                      value: '${attendance.totalClasses}',
                      icon: Icons.class_outlined,
                      iconColor: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AttendanceCard(
                      title: 'Attended',
                      value: '${attendance.attendedClasses}',
                      icon: Icons.check_circle_outline_rounded,
                      iconColor: AppColors.safe,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: AttendanceCard(
                      title: 'Absent',
                      value: '${attendance.absentClasses}',
                      icon: Icons.cancel_outlined,
                      iconColor: AppColors.danger,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AttendanceCard(
                      title: 'Target Required',
                      value: attendance.formattedTargetPercentage,
                      icon: Icons.flag_outlined,
                      iconColor: AppColors.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Action Buttons
              CustomButton(
                text: 'New Calculation',
                icon: Icons.replay_rounded,
                onPressed: () {
                  Navigator.pop(context); // Returns to input screen
                },
              ),
              const SizedBox(height: 12),

              CustomButton(
                text: 'Return to Dashboard',
                icon: Icons.home_rounded,
                isOutlined: true,
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
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

