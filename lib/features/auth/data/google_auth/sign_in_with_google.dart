import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SignInWithGoogle {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        '792931872361-sc45u0c4dh0tvsprnat2si7i762jp458.apps.googleusercontent.com',
    clientId:
        '792931872361-1cajorgndi4a5jpb7m150u145kpboggs.apps.googleusercontent.com',
  );

  GoogleSignInAccount? currentUser;

  Future<AuthResult?> signInWithGoogle({bool rememberMe = false}) async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return null;

      currentUser = account;
      final auth = await account.authentication;

      if (auth.accessToken == null) return null;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('user_logged_out', false);
      await prefs.setBool('remember_me', rememberMe);

      final status = await _sendToBackend(auth.accessToken!);
      return AuthResult(account: account, status: status);
    } catch (e) {
      print("Google Sign-In failed: $e");
      return null;
    }
  }

  Future<String> _sendToBackend(String accessToken) async {
    try {
      final response = await http.post(
        Uri.parse('https://readbuddy-server.onrender.com/api/users/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': currentUser?.displayName ?? '',
          'email': currentUser?.email ?? '',
          'picture': currentUser?.photoUrl ?? '',
          'userRole': 'user',
          'deviceInfo': {'deviceModel': 'Unknown', 'deviceOS': 'Unknown'}
        }),
      );

      if (response.statusCode == 200) {
        return 'registered';
      } else if (response.statusCode == 400 &&
          response.body.contains('User already exists')) {
        return 'login';
      } else {
        print('Backend error: ${response.statusCode}');
        print('Response: ${response.body}');
        return 'error';
      }
    } catch (e) {
      print("Error sending to backend: $e");
      return 'error';
    }
  }
}

class AuthResult {
  final GoogleSignInAccount account;
  final String status;

  AuthResult({
    required this.account,
    required this.status,
  });
}
