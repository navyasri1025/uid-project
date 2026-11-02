import 'package:flutter/material.dart';
import '../models/attendance_model.dart';
import '../routes/app_routes.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/responsive_content.dart';

/// Modern result screen showing predictions clearly.
class ResultScreen extends StatelessWidget {
  final AttendanceModel attendance;

  const ResultScreen({super.key, required this.attendance});

  @override
  Widget build(BuildContext context) {
    final isSafe = attendance.isSafe;
    final statusColor = isSafe ? AppColors.safe : AppColors.warning;
    final statusBg =
        isSafe ? AppColors.safeBackground : AppColors.warningBackground;
    final statusBorder = isSafe ? AppColors.safeBorder : AppColors.warningBorder;

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
        title: Text(
          attendance.name.isNotEmpty ? attendance.name : 'Result',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'View history',
            icon: const Icon(Icons.history_rounded,
                color: AppColors.textSecondary),
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.history),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
          child: ResponsiveContent(
            maxWidth: 680,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Status hero card ─────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(24),
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
                    children: [
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(30),
                          border:
                              Border.all(color: statusBorder, width: 1.2),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isSafe
                                  ? Icons.check_circle_rounded
                                  : Icons.warning_amber_rounded,
                              color: statusColor,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isSafe ? 'SAFE ZONE' : 'NEEDS IMPROVEMENT',
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Circular progress — current %
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(
                          begin: 0,
                          end: (attendance.currentPercentage / 100)
                              .clamp(0.0, 1.0),
                        ),
                        duration: const Duration(milliseconds: 900),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, _) => Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 140,
                              height: 140,
                              child: CircularProgressIndicator(
                                value: value,
                                strokeWidth: 12,
                                backgroundColor: AppColors.divider,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    statusColor),
                                strokeCap: StrokeCap.round,
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  attendance.formattedCurrentPercentage,
                                  style: const TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                    letterSpacing: -1,
                                  ),
                                ),
                                const Text(
                                  'Current',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Predicted bar
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Predicted (if all upcoming attended)',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                attendance.formattedPredictedPercentage,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: attendance.canReachTarget
                                      ? AppColors.safe
                                      : AppColors.danger,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(
                                begin: 0,
                                end: (attendance.predictedPercentage / 100)
                                    .clamp(0.0, 1.0)),
                            duration:
                                const Duration(milliseconds: 1000),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, _) => ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: value,
                                minHeight: 8,
                                backgroundColor: AppColors.divider,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  attendance.canReachTarget
                                      ? AppColors.primary
                                      : AppColors.warning,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Target: ${attendance.formattedTargetPercentage}',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textMuted),
                              ),
                              Text(
                                '${attendance.upcomingClasses} upcoming',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Quick stats row ──────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Can Miss',
                        value: '${attendance.classesCanMiss}',
                        valueColor:
                            isSafe ? AppColors.safe : AppColors.textPrimary,
                        icon: Icons.beach_access_rounded,
                        iconColor:
                            isSafe ? AppColors.safe : AppColors.textMuted,
                        note: isSafe
                            ? 'classes safely'
                            : 'No buffer',
                        highlighted: isSafe,
                        highlightBg: AppColors.safeBackground,
                        highlightBorder: AppColors.safeBorder,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        label: 'Classes Needed',
                        value: '${attendance.classesNeeded}',
                        valueColor: !isSafe
                            ? AppColors.warning
                            : AppColors.safe,
                        icon: Icons.trending_up_rounded,
                        iconColor: !isSafe
                            ? AppColors.warning
                            : AppColors.safe,
                        note: isSafe
                            ? 'Target met'
                            : 'to reach target',
                        highlighted: !isSafe,
                        highlightBg: AppColors.warningBackground,
                        highlightBorder: AppColors.warningBorder,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Class breakdown ──────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Class breakdown',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _BreakdownTile(
                            label: 'Total',
                            value: '${attendance.totalClasses}',
                            color: AppColors.primary,
                          ),
                          _BreakdownTile(
                            label: 'Attended',
                            value: '${attendance.attendedClasses}',
                            color: AppColors.safe,
                          ),
                          _BreakdownTile(
                            label: 'Absent',
                            value: '${attendance.absentClasses}',
                            color: AppColors.danger,
                          ),
                          _BreakdownTile(
                            label: 'Target',
                            value:
                                attendance.formattedTargetPercentage,
                            color: AppColors.secondary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Summary message ──────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          color: AppColors.primary, size: 19),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Prediction summary',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              attendance.statusMessage,
                              style: const TextStyle(
                                fontSize: 13,
                                height: 1.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── Action buttons ───────────────────────────────────
                LayoutBuilder(builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 500;
                  final newCalc = CustomButton(
                    text: 'New Calculation',
                    icon: Icons.replay_rounded,
                    onPressed: () => Navigator.pop(context),
                  );
                  final home = CustomButton(
                    text: 'Go to Home',
                    icon: Icons.home_rounded,
                    isOutlined: true,
                    onPressed: () => Navigator.popUntil(
                        context, (r) => r.isFirst),
                  );
                  return wide
                      ? Row(children: [
                          Expanded(child: newCalc),
                          const SizedBox(width: 14),
                          Expanded(child: home),
                        ])
                      : Column(children: [
                          newCalc,
                          const SizedBox(height: 12),
                          home,
                        ]);
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Local helpers ─────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final IconData icon;
  final Color iconColor;
  final String note;
  final bool highlighted;
  final Color highlightBg;
  final Color highlightBorder;

  const _StatCard({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.icon,
    required this.iconColor,
    required this.note,
    required this.highlighted,
    required this.highlightBg,
    required this.highlightBorder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlighted ? highlightBg : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: highlighted ? highlightBorder : AppColors.border,
            width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            note,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _BreakdownTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _BreakdownTile({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
