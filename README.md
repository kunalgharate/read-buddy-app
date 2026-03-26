# ReadBuddy App

A Flutter-based book sharing and reading companion app.

## Prerequisites

- Flutter SDK (stable channel)
- Dart SDK
- Java 17 (for Android builds)
- Android Studio / VS Code

## Setup

```bash
# Clone the repo
git clone https://github.com/kunalgharate/read-buddy-app.git
cd read-buddy-app

# Install dependencies
flutter pub get

# Generate code (DI, JSON serialization)
dart run build_runner build --delete-conflicting-outputs
```

## Run the App

```bash
# Debug mode
flutter run

# Release mode
flutter run --release

# Build APK
flutter build apk --release
```

## Code Quality Commands

### Dart Formatting

```bash
# Check formatting (dry run)
dart format --output=none --set-exit-if-changed .

# Apply formatting
dart format .
```

### Linter / Analyzer

```bash
# Run analyzer
dart analyze

# Run with fatal warnings (CI mode — fails on warnings)
dart analyze --fatal-infos

# Run with fatal errors only
dart analyze --fatal-warnings
```

### DCM (Dart Code Metrics)

```bash
# Install DCM
dart pub global activate dart_code_metrics

# Run metrics analysis
dart pub global run dart_code_metrics:metrics analyze lib

# Check unused code
dart pub global run dart_code_metrics:metrics check-unused-code lib

# Check unused files
dart pub global run dart_code_metrics:metrics check-unused-files lib
```

## CI/CD

The project uses GitHub Actions with two workflows:

- **Build APK** — builds a release APK on every PR, downloadable from Actions artifacts
- **Code Quality** — runs dart format, analyzer, and DCM on every PR and posts suggestions as a PR comment

Both workflows use concurrency groups to auto-cancel previous runs when new commits are pushed.

## Project Structure

```
lib/
├── app/                  # App-level config
├── core/                 # DI, network, utils, services
├── features/             # Feature modules (clean architecture)
│   ├── auth/             # Authentication
│   ├── onboarding/       # Onboarding screens
│   ├── questionaries/    # Onboarding questionnaire
│   ├── home/             # Home screen
│   ├── splash/           # Splash screen
│   └── ...
├── routes/               # App routing
└── main.dart             # Entry point
```
