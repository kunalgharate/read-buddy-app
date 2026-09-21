/// Environment-specific constants for development.
class DevConfig {
  DevConfig._();

  static const String baseUrl =
      'https://readbuddy-server-b54k.onrender.com/api';
  static const String appName = 'ReadBuddy Dev';

  /// Google OAuth **Web client ID** (from Google Cloud Console → Credentials).
  /// This MUST be the same client ID the backend verifies against
  /// (backend env GOOGLE_CLIENT_ID). It's passed to GoogleSignIn as
  /// `serverClientId` so the plugin returns an idToken with the correct
  /// audience for backend verification.
  /// <<< PASTE YOUR WEB CLIENT ID HERE (ends with .apps.googleusercontent.com) >>>
  static const String googleServerClientId =
      'PASTE_WEB_CLIENT_ID.apps.googleusercontent.com';
}
