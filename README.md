# Expense Tracker (Flutter + Firebase)

A clean expense tracker built with Flutter and Cloud Firestore, built as the practical task for the CyphLab Flutter Developer Internship.

**Live demo:** https://priyaforstudy0122.github.io/expense_tracker/
**APK:** (https://drive.google.com/file/d/1AreFwiXKbBZSqpHTDZsFZiXQgpxRKkqE/view?usp=drivesdk)
**Screen recording:** (https://drive.google.com/file/d/1nitx54ifD1R22R11ZeRvkr5JaoVoHzJF/view?usp=drivesdk)

## Features
- Add, edit and delete expenses (swipe left or tap the bin icon to delete)
- Category selection with colors and icons (Food, Travel, Bills, Shopping, Health, Entertainment, Other)
- Real-time storage in Cloud Firestore
- Total for the selected month with a month switcher
- Category-wise summary shown as a simple bar chart
- Expense history list, filtered by category and by month
- Search by title
- Form validation (title required, amount must be a number greater than 0)
- Loading, empty and error states (with a Retry button)
- Light and dark mode
- Responsive layout: content is centered and constrained on wide screens

## Tech stack / packages
- Flutter, Dart
- `firebase_core`, `cloud_firestore`
- `provider` (state management)
- `intl` (date and currency formatting)

## Project structure
```
lib/
  models/      expense.dart, category_style.dart
  services/    firestore_service.dart
  providers/   expense_provider.dart
  screens/     home_screen.dart, add_edit_screen.dart
  main.dart, theme.dart, firebase_options.dart
```

## Setup
1. Install the Flutter SDK and run `flutter doctor`.
2. Clone the repo and run `flutter pub get`.
3. Create a Firebase project and enable **Firestore Database**.
4. Install the FlutterFire CLI: `dart pub global activate flutterfire_cli`
5. Run `flutterfire configure` and select the Android and Web platforms. This regenerates `lib/firebase_options.dart`.
6. Run the app:
   - Web: `flutter run -d chrome`
   - Android: `flutter run`
7. Build a release APK: `flutter build apk --release`

> Firestore rules are open for demo purposes only. Lock them down before using real data.

## AI tools used
- **Claude (Anthropic)**: planned the project structure, wrote the Provider and Firestore code, helped design the UI, and helped debug environment and build errors.

I reviewed and tested all the generated code, and I can explain how each part works.
