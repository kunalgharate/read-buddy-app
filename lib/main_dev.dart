import 'package:read_buddy_app/core/config/app_config.dart';
import 'package:read_buddy_app/core/config/dev_config.dart';
import 'package:read_buddy_app/main.dart' as app;

/// Development entry point.
/// Run with: flutter run --flavor dev -t lib/main_dev.dart
void main() {
  AppConfig.init(
    environment: Environment.dev,
    baseUrl: DevConfig.baseUrl,
    appName: DevConfig.appName,
  );
  app.main();
}
