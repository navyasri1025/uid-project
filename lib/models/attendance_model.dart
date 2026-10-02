/// Data model representing an attendance calculation and prediction record.
class AttendanceModel {
  /// Total classes conducted so far.
  final int totalClasses;

  /// Total classes attended by the student.
  final int attendedClasses;

  /// Total classes absent.
  final int absentClasses;

  /// Student's target attendance percentage (e.g. 75.0).
  final double targetPercentage;

  /// Number of upcoming classes planned/conducted in the future.
  final int upcomingClasses;

  /// Current calculated attendance percentage: (attended / total) * 100.
  final double currentPercentage;

  /// Predicted attendance percentage if student attends all upcoming classes.
  final double predictedPercentage;

  /// Number of classes the student can safely miss while maintaining target.
  final int classesCanMiss;

  /// Additional consecutive classes the student must attend to reach target.
  final int classesNeeded;

  /// Whether current attendance is at or above the target percentage.
  final bool isSafe;

  /// Whether the target is achievable if the student attends all upcoming classes.
  final bool canReachTarget;

  /// Detailed human-readable explanation of the prediction result.
  final String statusMessage;

  /// Local timestamp when the calculation was performed.
  final DateTime timestamp;

  const AttendanceModel({
    required this.totalClasses,
    required this.attendedClasses,
    required this.absentClasses,
    required this.targetPercentage,
    required this.upcomingClasses,
    required this.currentPercentage,
    required this.predictedPercentage,
    required this.classesCanMiss,
    required this.classesNeeded,
    required this.isSafe,
    required this.canReachTarget,
    required this.statusMessage,
    required this.timestamp,
  });

  /// Formatted current percentage as string with 2 decimal places.
  String get formattedCurrentPercentage => '${currentPercentage.toStringAsFixed(1)}%';

  /// Formatted predicted percentage as string with 2 decimal places.
  String get formattedPredictedPercentage => '${predictedPercentage.toStringAsFixed(1)}%';

  /// Formatted target percentage as string.
  String get formattedTargetPercentage => '${targetPercentage.toStringAsFixed(1)}%';

  /// Formatted date and time for history display.
  String get formattedDate {
    final day = timestamp.day.toString().padLeft(2, '0');
    final month = timestamp.month.toString().padLeft(2, '0');
    final year = timestamp.year;
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }
}

