import 'package:flutter/material.dart';
import '../models/attendance_model.dart';
import '../routes/app_routes.dart';
import '../services/attendance_calculator.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/responsive_content.dart';

/// History screen showing the latest calculation from the current session.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  void _confirmClear() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear history?'),
        content: const Text(
            'This will remove all session calculations. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              setState(() => AttendanceCalculator.clearHistory());
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('History cleared.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final history = AttendanceCalculator.sessionHistory;
    final latest = history.isEmpty ? null : history.first;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'History',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          if (history.isNotEmpty)
            IconButton(
              tooltip: 'Clear history',
              icon: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.danger),
              onPressed: _confirmClear,
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: ResponsiveContent(
              maxWidth: 520,
              child: latest == null
                  ? _EmptyState(
                      onCalculate: () => Navigator.pushReplacementNamed(
                          context, AppRoutes.input),
                    )
                  : _LatestCard(
                      record: latest,
                      onOpen: () => Navigator.pushNamed(
                        context,
                        AppRoutes.result,
                        arguments: latest,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Latest calculation card ───────────────────────────────────────────────

class _LatestCard extends StatelessWidget {
  final AttendanceModel record;
  final VoidCallback onOpen;

  const _LatestCard({required this.record, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final isSafe = record.isSafe;
    final statusColor = isSafe ? AppColors.safe : AppColors.warning;
    final statusBg =
        isSafe ? AppColors.safeBackground : AppColors.warningBackground;
    final statusBorder =
        isSafe ? AppColors.safeBorder : AppColors.warningBorder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section label
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            'Latest calculation',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
              color: AppColors.textSecondary,
            ),
          ),
        ),

        // Main card
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.textPrimary.withValues(alpha: 0.05),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name row + status badge
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      isSafe
                          ? Icons.verified_rounded
                          : Icons.trending_up_rounded,
                      color: statusColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.name.isNotEmpty
                              ? record.name
                              : 'Unnamed record',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          record.formattedDate,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: statusBorder, width: 1.2),
                    ),
                    child: Text(
                      isSafe ? 'SAFE' : 'ATTENTION',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(height: 1, color: AppColors.divider),
              const SizedBox(height: 20),

              // Metrics grid
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _MetricItem(
                    label: 'Current',
                    value: record.formattedCurrentPercentage,
                    color: statusColor,
                  ),
                  _MetricItem(
                    label: 'Target',
                    value: record.formattedTargetPercentage,
                    color: AppColors.textPrimary,
                  ),
                  _MetricItem(
                    label: 'Predicted',
                    value: record.formattedPredictedPercentage,
                    color: record.canReachTarget
                        ? AppColors.safe
                        : AppColors.danger,
                  ),
                  _MetricItem(
                    label: isSafe ? 'Can Miss' : 'Need',
                    value: isSafe
                        ? '${record.classesCanMiss}'
                        : '${record.classesNeeded}',
                    color: isSafe ? AppColors.safe : AppColors.warning,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Attendance progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (record.currentPercentage / 100).clamp(0.0, 1.0),
                  minHeight: 7,
                  backgroundColor: AppColors.divider,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(statusColor),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${record.attendedClasses} of ${record.totalClasses} classes attended',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Open full report button
        CustomButton(
          text: 'Open Full Report',
          icon: Icons.open_in_new_rounded,
          onPressed: onOpen,
        ),
        const SizedBox(height: 12),

        CustomButton(
          text: 'New Calculation',
          icon: Icons.add_rounded,
          isOutlined: true,
          onPressed: () =>
              Navigator.pushNamed(context, AppRoutes.input),
        ),

        // Note about session scope
        const SizedBox(height: 24),
        const Center(
          child: Text(
            'History is kept for this session only.',
            style: TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
                fontStyle: FontStyle.italic),
          ),
        ),
      ],
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

// ─── Empty state ───────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onCalculate;
  const _EmptyState({required this.onCalculate});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 60),
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.history_rounded,
              size: 36, color: AppColors.primary),
        ),
        const SizedBox(height: 20),
        const Text(
          'No history yet',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Calculations you make will appear here.',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5),
        ),
        const SizedBox(height: 32),
        CustomButton(
          text: 'Calculate Attendance',
          icon: Icons.calculate_rounded,
          onPressed: onCalculate,
        ),
        const SizedBox(height: 60),
      ],
    );
  }
}
