/// Environment-specific constants for production.
/// TODO: Update the baseUrl once the production server is deployed.
class ProdConfig {
  ProdConfig._();

  static const String baseUrl = 'https://readbuddy-production.onrender.com/api';
  static const String appName = 'ReadBuddy';

  /// Google OAuth **Web client ID** (from Google Cloud Console → Credentials).
  /// Must match the backend env GOOGLE_CLIENT_ID used to verify the idToken.
  /// Usually the SAME Web client ID as dev (one GCP project); if prod uses a
  /// separate project, paste that project's Web client ID here.
  /// <<< PASTE YOUR WEB CLIENT ID HERE (ends with .apps.googleusercontent.com) >>>
  static const String googleServerClientId =
      'PASTE_WEB_CLIENT_ID.apps.googleusercontent.com';
}
