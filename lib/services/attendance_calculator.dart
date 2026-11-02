import 'dart:math';
import '../models/attendance_model.dart';

/// AttendanceCalculator contains all core business logic and mathematical
/// calculations for attendance analysis and prediction.
///
/// Designed cleanly with no external dependencies or APIs.
class AttendanceCalculator {
  /// Session-based history list to store past calculations.
  static final List<AttendanceModel> sessionHistory = [];

  /// Validates input values. Returns null if all valid, or an error message string.
  static String? validateInputs({
    required int? totalClasses,
    required int? attendedClasses,
    required int? absentClasses,
    required double? targetPercentage,
    required int? upcomingClasses,
  }) {
    if (totalClasses == null ||
        attendedClasses == null ||
        absentClasses == null ||
        targetPercentage == null ||
        upcomingClasses == null) {
      return 'Please fill in all the required fields.';
    }

    if (totalClasses <= 0) {
      return 'Total classes conducted must be greater than 0.';
    }

    if (attendedClasses < 0) {
      return 'Attended classes cannot be negative.';
    }

    if (absentClasses < 0) {
      return 'Absent classes cannot be negative.';
    }

    if (upcomingClasses < 0) {
      return 'Upcoming classes cannot be negative.';
    }

    if (attendedClasses > totalClasses) {
      return 'Attended classes cannot be greater than total classes conducted.';
    }

    if (absentClasses > totalClasses) {
      return 'Absent classes cannot be greater than total classes conducted.';
    }

    if (attendedClasses + absentClasses > totalClasses) {
      return 'Sum of attended ($attendedClasses) and absent ($absentClasses) '
          'cannot exceed total classes conducted ($totalClasses).';
    }

    if (targetPercentage <= 0 || targetPercentage > 100) {
      return 'Target percentage must be between 1% and 100%.';
    }

    return null; // Valid
  }

  /// Calculates attendance metrics and returns a populated [AttendanceModel].
  static AttendanceModel calculate({
    String name = '',
    required int totalClasses,
    required int attendedClasses,
    required int absentClasses,
    required double targetPercentage,
    required int upcomingClasses,
  }) {
    // 1. Current attendance percentage: (attended / total) * 100
    final double currentPercentage = (attendedClasses / totalClasses) * 100;

    // 2. Predicted attendance if student attends all upcoming classes:
    //    ((attended + upcoming) / (total + upcoming)) * 100
    final int totalFutureClasses = totalClasses + upcomingClasses;
    final int totalFutureAttended = attendedClasses + upcomingClasses;
    final double predictedPercentage = totalFutureClasses > 0
        ? (totalFutureAttended / totalFutureClasses) * 100
        : currentPercentage;

    final double targetFraction = targetPercentage / 100.0;
    final bool isSafe = currentPercentage >= targetPercentage;
    final bool canReachTarget = predictedPercentage >= targetPercentage;

    int classesCanMiss = 0;
    int classesNeeded = 0;
    String statusMessage = '';

    if (isSafe) {
      // Student is currently safe (current >= target)
      // Formula for classes that can be missed right now:
      // attended / (total + M) >= targetFraction
      // M <= (attended / targetFraction) - total
      if (targetFraction > 0) {
        final double maxMissable =
            (attendedClasses / targetFraction) - totalClasses;
        classesCanMiss = max(0, maxMissable.floor());
      }

      statusMessage =
          'Great job! You are in the SAFE zone. Your current attendance is '
          '${currentPercentage.toStringAsFixed(1)}%, which exceeds your target of '
          '${targetPercentage.toStringAsFixed(1)}%. You can safely miss up to '
          '$classesCanMiss class${classesCanMiss == 1 ? '' : 'es'} without '
          'falling below your target.';
    } else {
      // Student is below target (current < target)
      // Formula for consecutive classes needed to reach target:
      // (attended + N) / (total + N) >= targetFraction
      // N * (1 - targetFraction) >= (targetFraction * total - attended)
      // N >= (targetFraction * total - attended) / (1 - targetFraction)
      if (targetFraction >= 1.0) {
        // Target is 100%, but student has already missed at least one class
        classesNeeded = 9999;
        statusMessage =
            'Your target is 100%, but since you have already missed classes, '
            'reaching exactly 100% is no longer mathematically possible.';
      } else {
        final double numerator =
            (targetFraction * totalClasses) - attendedClasses;
        final double denominator = 1.0 - targetFraction;
        final double needed = numerator / denominator;
        classesNeeded = max(1, needed.ceil());

        if (canReachTarget) {
          statusMessage =
              'Attention: You NEED IMPROVEMENT. Your current attendance is '
              '${currentPercentage.toStringAsFixed(1)}%. You must attend at least '
              '$classesNeeded consecutive class${classesNeeded == 1 ? '' : 'es'} '
              'to reach your target of ${targetPercentage.toStringAsFixed(1)}%. '
              'With $upcomingClasses upcoming classes, you CAN achieve this target!';
        } else {
          statusMessage =
              'Warning: You NEED IMPROVEMENT. Your current attendance is '
              '${currentPercentage.toStringAsFixed(1)}%. You need $classesNeeded '
              'classes to reach ${targetPercentage.toStringAsFixed(1)}%. Even if you '
              'attend all $upcomingClasses upcoming classes, your attendance will '
              'reach ${predictedPercentage.toStringAsFixed(1)}%. You will need '
              'additional classes this semester to recover.';
        }
      }
    }

    final record = AttendanceModel(
      name: name.trim(),
      totalClasses: totalClasses,
      attendedClasses: attendedClasses,
      absentClasses: absentClasses,
      targetPercentage: targetPercentage,
      upcomingClasses: upcomingClasses,
      currentPercentage: currentPercentage,
      predictedPercentage: predictedPercentage,
      classesCanMiss: classesCanMiss,
      classesNeeded: classesNeeded,
      isSafe: isSafe,
      canReachTarget: canReachTarget,
      statusMessage: statusMessage,
      timestamp: DateTime.now(),
    );

    // Save to local in-memory session history
    sessionHistory.insert(0, record);

    return record;
  }

  /// Clears the session history.
  static void clearHistory() {
    sessionHistory.clear();
  }
}
