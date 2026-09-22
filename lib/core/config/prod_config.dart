/// Environment-specific constants for production.
/// TODO: Update the baseUrl once the production server is deployed.
class ProdConfig {
  ProdConfig._();

  static const String baseUrl = 'https://readbuddy-production.onrender.com/api';
  static const String appName = 'ReadBuddy';

  /// Google OAuth **Web client ID** — MUST equal the backend env
  /// GOOGLE_CLIENT_ID (token audience). If prod uses a different GCP project,
  /// replace with that project's Web client ID.
  static const String googleServerClientId =
      '740720099305-1i0mhiop2816irdg5i93nk8ihmn84h4q.apps.googleusercontent.com';
}
