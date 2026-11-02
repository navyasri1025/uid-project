# Attendance Predictor

## 1. Aim

To develop a Flutter application that helps students understand their current attendance and estimate how future classes may affect it.

## 2. Objective

- Calculate current attendance from the number of classes attended and conducted.
- Compare the result with a user-selected attendance target.
- Estimate attendance if the student attends all upcoming classes.
- Show how many classes can be missed while keeping the current target, or how many consecutive classes are needed to reach it.
- Label calculations with a student or course name so they are easier to identify in the in-app history.

## 3. Project Description

Attendance Predictor is a student-focused application built with Flutter. The user enters a name for the record, the classes conducted, classes attended and absent, an attendance target, and the number of upcoming classes. The app validates the values and calculates attendance percentages and class recommendations.

The result screen presents the prediction and class breakdown. Calculations are added to a history list that can be viewed during the current app session. This history is kept in memory and is cleared when the app session ends; it is not permanent storage.

## 4. Technologies Used

- **Flutter** — application framework and UI toolkit.
- **Dart** — programming language and attendance calculation logic.
- **Material Design 3 widgets** — application screens, forms, navigation, and controls.
- **Cupertino Icons** — icon package included as a project dependency.

The project does not use a database, backend service, or external API.

## 5. System Requirements

- Flutter SDK with Dart 3 or later, as specified by `pubspec.yaml`.
- A computer supported by the Flutter SDK (Windows, macOS, or Linux).
- An editor or IDE such as Visual Studio Code or Android Studio.
- For browser execution: an installed browser supported by Flutter, such as Chrome or Edge.
- For other targets: the corresponding device, emulator, or desktop toolchain configured in Flutter.
- Internet access may be needed the first time Flutter downloads project dependencies.

## 6. Features

- Input a name for each attendance estimate.
- Enter total classes, attended classes, absent classes, attendance target, and upcoming classes.
- Automatically calculate absent classes from total minus attended when the attendance input changes.
- Validate required values and prevent invalid attendance counts or target percentages.
- Use quick target presets of 65%, 75%, 80%, and 85%.
- Show current attendance and the forecast when all specified upcoming classes are attended.
- Identify whether the current attendance is at the target and whether the target is reachable with the specified upcoming classes.
- Estimate the number of classes that can be missed or the number of classes needed to reach the target.
- View a detailed prediction, class breakdown, and named calculation history.
- Clear the in-session calculation history.
- Use a Material 3 interface with a home dashboard, input form, results, and history screens.

## 7. Project Structure

```text
.
├── android/                     # Android platform project
├── ios/                         # iOS platform project
├── linux/                       # Linux desktop platform project
├── macos/                       # macOS desktop platform project
├── web/                         # Flutter web entry point and assets
├── windows/                     # Windows desktop platform project
├── lib/
│   ├── main.dart                # Application entry point and MaterialApp
│   ├── models/
│   │   └── attendance_model.dart
│   ├── routes/
│   │   └── app_routes.dart      # Named route definitions
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── attendance_input_screen.dart
│   │   ├── result_screen.dart
│   │   └── history_screen.dart
│   ├── services/
│   │   └── attendance_calculator.dart
│   ├── utils/
│   │   ├── app_colors.dart
│   │   └── app_theme.dart
│   └── widgets/
│       ├── attendance_card.dart
│       ├── custom_button.dart
│       └── prediction_result.dart
├── test/                        # Project test source files
├── pubspec.yaml                 # Dependencies and Dart SDK constraint
└── README.md
```

## 8. Installation and Execution Procedure

1. Install the Flutter SDK and a supported browser or device. Follow the Flutter installation guide in the References section.
2. Open a terminal in the project root directory (the directory containing `pubspec.yaml`).
3. Check the Flutter setup:

   ```bash
   flutter doctor
   ```

4. Download the project dependencies:

   ```bash
   flutter pub get
   ```

5. To run in Chrome, first confirm it is available as a Flutter device, then start the app:

   ```bash
   flutter devices
   flutter run -d chrome
   ```

   To use another configured target, replace `chrome` with its device identifier from `flutter devices`.

6. Alternatively, start a web server and open the shown local URL in a browser:

   ```bash
   flutter run -d web-server --web-port 8080
   ```

   Open `http://localhost:8080` in the browser.

## 9. Output

When the application starts, the home dashboard provides options to calculate attendance or view recent calculations. After submitting valid attendance data, the result screen shows the named estimate, current and predicted attendance, target status, class counts, and attendance recommendations. The history screen lists calculations from the current app session and lets the user reopen a result or clear the list.

## 10. Conclusion

The Attendance Predictor application demonstrates how Flutter and Dart can be used to build a student utility with form validation, attendance calculations, forecasting, and interactive result screens. It provides quick attendance guidance and keeps named estimates available in history for the duration of an app session.

## 11. References

- [Flutter documentation](https://docs.flutter.dev/)
- [Flutter installation guide](https://docs.flutter.dev/get-started/install)
- [Flutter web deployment and development](https://docs.flutter.dev/platform-integration/web)
- [Dart documentation](https://dart.dev/guides)
- [Material Design 3](https://m3.material.io/)
