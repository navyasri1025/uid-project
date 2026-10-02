import 'package:flutter_test/flutter_test.dart';
import 'package:attendance_predictor/services/attendance_calculator.dart';

void main() {
  setUp(() {
    AttendanceCalculator.clearHistory();
  });

  group('AttendanceCalculator Validation Tests', () {
    test('rejects null inputs', () {
      final error = AttendanceCalculator.validateInputs(
        totalClasses: null,
        attendedClasses: 10,
        absentClasses: 2,
        targetPercentage: 75,
        upcomingClasses: 5,
      );
      expect(error, contains('Please fill in all the required fields'));
    });

    test('rejects totalClasses <= 0 (prevents division by zero)', () {
      final error = AttendanceCalculator.validateInputs(
        totalClasses: 0,
        attendedClasses: 0,
        absentClasses: 0,
        targetPercentage: 75,
        upcomingClasses: 5,
      );
      expect(error, contains('Total classes conducted must be greater than 0'));
    });

    test('rejects negative values', () {
      final error = AttendanceCalculator.validateInputs(
        totalClasses: 10,
        attendedClasses: -1,
        absentClasses: 0,
        targetPercentage: 75,
        upcomingClasses: 5,
      );
      expect(error, contains('cannot be negative'));
    });

    test('rejects attended > total', () {
      final error = AttendanceCalculator.validateInputs(
        totalClasses: 10,
        attendedClasses: 12,
        absentClasses: 0,
        targetPercentage: 75,
        upcomingClasses: 5,
      );
      expect(error, contains('cannot be greater than total classes'));
    });

    test('rejects attended + absent > total', () {
      final error = AttendanceCalculator.validateInputs(
        totalClasses: 10,
        attendedClasses: 8,
        absentClasses: 4,
        targetPercentage: 75,
        upcomingClasses: 5,
      );
      expect(error, contains('cannot exceed total classes conducted'));
    });

    test('rejects targetPercentage > 100 or <= 0', () {
      final errorOver = AttendanceCalculator.validateInputs(
        totalClasses: 10,
        attendedClasses: 8,
        absentClasses: 2,
        targetPercentage: 105,
        upcomingClasses: 5,
      );
      expect(errorOver, contains('must be between 1% and 100%'));

      final errorZero = AttendanceCalculator.validateInputs(
        totalClasses: 10,
        attendedClasses: 8,
        absentClasses: 2,
        targetPercentage: 0,
        upcomingClasses: 5,
      );
      expect(errorZero, contains('must be between 1% and 100%'));
    });
  });

  group('AttendanceCalculator Math and Prediction Tests', () {
    test('Calculates Safe Status with classes that can be missed correctly', () {
      // 80 attended out of 100 conducted, Target: 75%
      // Current: 80%
      // Classes missable: (80 / 0.75) - 100 = 106.666 - 100 = 6 classes
      // If student misses 6: 80 / 106 = 75.47% (>= 75%)
      final result = AttendanceCalculator.calculate(
        totalClasses: 100,
        attendedClasses: 80,
        absentClasses: 20,
        targetPercentage: 75.0,
        upcomingClasses: 10,
      );

      expect(result.currentPercentage, 80.0);
      expect(result.isSafe, true);
      expect(result.classesCanMiss, 6);
      expect(result.classesNeeded, 0);
      expect(result.predictedPercentage, closeTo(81.81, 0.05));
      expect(result.canReachTarget, true);
    });

    test('Calculates Need Improvement with classes needed to recover', () {
      // 60 attended out of 100 conducted, Target: 75%
      // Current: 60%
      // Classes needed: (0.75 * 100 - 60) / (1 - 0.75) = 15 / 0.25 = 60
      final result = AttendanceCalculator.calculate(
        totalClasses: 100,
        attendedClasses: 60,
        absentClasses: 40,
        targetPercentage: 75.0,
        upcomingClasses: 60,
      );

      expect(result.currentPercentage, 60.0);
      expect(result.isSafe, false);
      expect(result.classesCanMiss, 0);
      expect(result.classesNeeded, 60);
      expect(result.predictedPercentage, 75.0);
      expect(result.canReachTarget, true);
    });

    test('Correctly identifies when upcoming classes are insufficient to reach target', () {
      // 50 attended out of 100 conducted, Target: 75%
      // Upcoming: only 10 classes
      // Predicted: (50 + 10) / (100 + 10) = 60 / 110 = 54.54% < 75%
      final result = AttendanceCalculator.calculate(
        totalClasses: 100,
        attendedClasses: 50,
        absentClasses: 50,
        targetPercentage: 75.0,
        upcomingClasses: 10,
      );

      expect(result.isSafe, false);
      expect(result.canReachTarget, false);
      expect(result.predictedPercentage, closeTo(54.54, 0.05));
    });

    test('Session history records calculations and supports clearHistory', () {
      expect(AttendanceCalculator.sessionHistory.length, 0);

      AttendanceCalculator.calculate(
        totalClasses: 50,
        attendedClasses: 40,
        absentClasses: 10,
        targetPercentage: 75.0,
        upcomingClasses: 10,
      );

      expect(AttendanceCalculator.sessionHistory.length, 1);

      AttendanceCalculator.clearHistory();
      expect(AttendanceCalculator.sessionHistory.length, 0);
    });
  });
}

