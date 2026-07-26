/// App environment configuration.
/// Switch between dev and prod via the entry point (main_dev / main_prod).
enum Environment { dev, prod }

class AppConfig {
  static AppConfig? _instance;

  final Environment environment;
  final String baseUrl;
  final String appName;

  AppConfig._({
    required this.environment,
    required this.baseUrl,
    required this.appName,
  });

  static bool get isInitialized => _instance != null;

  static AppConfig get instance {
    if (_instance == null) {
      throw StateError(
          'AppConfig.init() must be called before accessing instance');
    }
    return _instance!;
  }

  static void init({
    required Environment environment,
    required String baseUrl,
    required String appName,
  }) {
    _instance = AppConfig._(
      environment: environment,
      baseUrl: baseUrl,
      appName: appName,
    );
  }

  bool get isDev => environment == Environment.dev;
  bool get isProd => environment == Environment.prod;
}
