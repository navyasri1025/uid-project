import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:attendance_predictor/main.dart';
import 'package:attendance_predictor/services/attendance_calculator.dart';

void main() {
  setUp(() {
    AttendanceCalculator.clearHistory();
  });

  testWidgets('Complete end-to-end user journey test: Input -> Result -> History', (WidgetTester tester) async {
    // 1. Launch the application
    await tester.pumpWidget(const AttendancePredictorApp());
    await tester.pumpAndSettle();

    // Verify HomeScreen is rendered
    expect(find.text('Attendance Predictor'), findsWidgets);
    expect(find.text('Predict & Protect Your Attendance'), findsOneWidget);

    // 2. Scroll to and tap "Calculate Attendance" button to go to AttendanceInputScreen
    final calculateBtn = find.widgetWithText(ElevatedButton, 'Calculate Attendance');
    await tester.ensureVisible(calculateBtn);
    await tester.pumpAndSettle();
    await tester.tap(calculateBtn);
    await tester.pumpAndSettle();

    // Verify AttendanceInputScreen is loaded
    expect(find.text('Enter Attendance Data'), findsOneWidget);

    // 3. Fill the form fields:
    final textFields = find.byType(TextFormField);
    expect(textFields, findsNWidgets(5));

    await tester.enterText(textFields.at(0), '100'); // Total
    await tester.enterText(textFields.at(1), '80');  // Attended
    await tester.enterText(textFields.at(2), '20');  // Absent
    await tester.enterText(textFields.at(3), '75');  // Target
    await tester.enterText(textFields.at(4), '10');  // Upcoming
    await tester.pumpAndSettle();

    // 4. Scroll to and tap "Calculate & Predict"
    final submitBtn = find.widgetWithText(ElevatedButton, 'Calculate & Predict');
    await tester.ensureVisible(submitBtn);
    await tester.pumpAndSettle();
    await tester.tap(submitBtn);
    await tester.pumpAndSettle();

    // 5. Verify ResultScreen is loaded with accurate calculations
    expect(find.text('Attendance Prediction'), findsOneWidget);
    expect(find.text('SAFE ZONE'), findsOneWidget);
    expect(find.text('80.0%'), findsOneWidget);
    expect(find.text('6'), findsOneWidget); // Can miss 6 classes

    // 6. Scroll to and tap "Return to Dashboard"
    final returnBtn = find.widgetWithText(OutlinedButton, 'Return to Dashboard');
    await tester.ensureVisible(returnBtn);
    await tester.pumpAndSettle();
    await tester.tap(returnBtn);
    await tester.pumpAndSettle();

    // Verify back on HomeScreen with Latest Calculation card
    expect(find.text('Latest Calculation'), findsOneWidget);

    // 7. Navigate to HistoryScreen
    final historyIcon = find.byTooltip('View Calculation History');
    await tester.tap(historyIcon);
    await tester.pumpAndSettle();

    // Verify HistoryScreen shows the calculated record
    expect(find.text('Calculation History'), findsOneWidget);
    expect(find.text('SAFE'), findsOneWidget);
    expect(find.text('80.0%'), findsOneWidget);

    // 8. Test clearing history
    final clearBtn = find.byTooltip('Clear History');
    await tester.tap(clearBtn);
    await tester.pumpAndSettle();

    // Tap confirm in dialog
    final confirmClear = find.widgetWithText(ElevatedButton, 'Clear');
    await tester.tap(confirmClear);
    await tester.pumpAndSettle();

    // Verify empty state is displayed
    expect(find.text('No History Yet'), findsOneWidget);
  });
}
