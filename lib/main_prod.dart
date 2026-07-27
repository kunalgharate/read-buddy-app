import 'package:read_buddy_app/core/config/app_config.dart';
import 'package:read_buddy_app/core/config/prod_config.dart';
import 'package:read_buddy_app/main.dart' as app;

/// Production entry point.
/// Run with: flutter run --flavor prod -t lib/main_prod.dart
/// Build with: flutter build apk --flavor prod -t lib/main_prod.dart
void main() {
  AppConfig.init(
    environment: Environment.prod,
    baseUrl: ProdConfig.baseUrl,
    appName: ProdConfig.appName,
  );
  app.main();
}
