/// Environment-specific constants for development.
class DevConfig {
  DevConfig._();

  static const String baseUrl =
      'https://readbuddy-server-b54k.onrender.com/api';
  static const String appName = 'ReadBuddy Dev';

  /// Google OAuth **Web client ID** — MUST equal the backend env
  /// GOOGLE_CLIENT_ID (the token audience the backend verifies). Passed to
  /// GoogleSignIn as `serverClientId` so the plugin returns a backend-verifiable
  /// idToken.
  static const String googleServerClientId =
      '740720099305-1i0mhiop2816irdg5i93nk8ihmn84h4q.apps.googleusercontent.com';
}
