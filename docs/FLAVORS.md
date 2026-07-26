# Product Flavors / Environments

ReadBuddy uses **product flavors** to separate Development and Production environments.

## Structure

```
lib/
├── core/config/
│   ├── app_config.dart       # Singleton holding current environment config
│   ├── dev_config.dart       # Dev-specific values (base URL, app name)
│   └── prod_config.dart      # Prod-specific values (base URL, app name)
├── main.dart                 # Shared app code (defaults to dev if run directly)
├── main_dev.dart             # Entry point for development
└── main_prod.dart            # Entry point for production
```

## Running the App

### Development
```bash
# Android
flutter run --flavor dev -t lib/main_dev.dart

# iOS
flutter run --flavor dev -t lib/main_dev.dart

# Or simply (defaults to dev):
flutter run
```

### Production
```bash
# Android
flutter run --flavor prod -t lib/main_prod.dart

# iOS
flutter run --flavor prod -t lib/main_prod.dart
```

## Building

### Development APK
```bash
flutter build apk --flavor dev -t lib/main_dev.dart
```

### Production APK
```bash
flutter build apk --flavor prod -t lib/main_prod.dart --release
```

### Production App Bundle (Play Store)
```bash
flutter build appbundle --flavor prod -t lib/main_prod.dart --release
```

### iOS Archive (Production)
```bash
flutter build ipa --flavor prod -t lib/main_prod.dart --release
```

## Configuration

### Changing URLs

Edit the config files:
- **Dev URL**: `lib/core/config/dev_config.dart`
- **Prod URL**: `lib/core/config/prod_config.dart`

### Android

| Flavor | App ID | App Name |
|--------|--------|----------|
| dev | `in.thecodershub.readbuddy.dev` | ReadBuddy Dev |
| prod | `in.thecodershub.readbuddy` | ReadBuddy |

Both flavors share the same Firebase project (`google-services.json` copied to both `src/dev/` and `src/prod/`).

### iOS

| Flavor | Bundle ID | Display Name |
|--------|-----------|--------------|
| dev | `in.thecodershub.readbuddy.dev` | ReadBuddy Dev |
| prod | `in.thecodershub.readbuddy` | ReadBuddy |

iOS uses separate Xcode schemes (`dev` / `prod`) mapped to build configurations:
- `Debug-dev` / `Release-dev`
- `Debug-prod` / `Release-prod`

Both share the same `GoogleService-Info.plist`.

### iOS Setup (One-time in Xcode)

After pulling these changes, open `ios/Runner.xcworkspace` in Xcode and:

1. Go to **Runner** target → **Build Settings**
2. Add custom build configurations:
   - `Debug-dev` (duplicate of Debug)
   - `Release-dev` (duplicate of Release)
   - `Debug-prod` (duplicate of Debug)
   - `Release-prod` (duplicate of Release)
3. For each config, set the correct `.xcconfig` file:
   - `Debug-dev` → `Flutter/Debug-dev.xcconfig`
   - `Release-dev` → `Flutter/Release-dev.xcconfig`
   - `Debug-prod` → `Flutter/Debug-prod.xcconfig`
   - `Release-prod` → `Flutter/Release-prod.xcconfig`
4. The schemes (`dev` / `prod`) are already created in `xcshareddata/xcschemes/`

## VS Code Launch Configs

Add to `.vscode/launch.json`:
```json
{
  "configurations": [
    {
      "name": "Dev",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_dev.dart",
      "toolArgs": ["--flavor", "dev"]
    },
    {
      "name": "Prod",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_prod.dart",
      "toolArgs": ["--flavor", "prod"]
    }
  ]
}
```
