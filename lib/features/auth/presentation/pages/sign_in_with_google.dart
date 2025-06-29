//Sign In With Google

import 'dart:convert' show json;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Your scopes

class SignInWithGoogle {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        '792931872361-kkc5l707rubeil9c7mvre3lnob7nsl03.apps.googleusercontent.com',
    clientId:
        '792931872361-7jfmhcaksih17sdg9gfn2d2rg0iloi75.apps.googleusercontent.com',
  );

  GoogleSignInAccount? currentUser;
  bool isAuthorized = false;
  String? contactName;
  String? serverAuthCode;
  Future<AuthResult?> signInRespectingLogout() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedOut = prefs.getBool('user_logged_out') ?? false;

    if (loggedOut) {
      return await _signInWithPicker(); // show account picker
    } else {
      return await _signInSilently(); // auto sign-in
    }
  }

  // Basic sign in
  Future<AuthResult?> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      currentUser = account;

      if (account != null) {
        final auth = await account.authentication;

        debugPrint('Access Token: ${auth.accessToken}');
        debugPrint('ID Token: ${auth.idToken}');

        isAuthorized = auth.accessToken != null;

        if (isAuthorized) {
          final status = await _fetchContact(auth.accessToken!);
          return AuthResult(account: account, status: status);

          // if (backendSuccess) {
          //   return account; // Backend registered or already existed
          // } else {
          //   debugPrint('Backend rejected registration.');
          //   return null;
          // }
        }
      }
    } catch (e) {
      debugPrint("Google Sign-In failed: $e");
    }

    return null;
  }

  // Sign out and clear state
  Future<void> signOut() async {
    await _googleSignIn.disconnect();
    currentUser = null;
    isAuthorized = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('user_logged_out', true);
  }

  Future<void> clearLogoutFlag() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('user_logged_out', false);
  }

  // Send accessToken and data to your backend
  Future<String> _fetchContact(String accessToken) async {
    final response = await http.post(
      Uri.parse('https://readbuddy-server.onrender.com/api/users/register'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'name': currentUser?.displayName ?? '',
        'email': currentUser?.email ?? '',
        'password': 'google_auth_default',
        'phno': '0000000000',
        'userRole': 'user',
        'picture': currentUser?.photoUrl ?? '',
        'deviceInfo': {
          'deviceModel': 'Unknown',
          'deviceOS': 'Unknown',
        },
      }),
    );

    if (response.statusCode == 200) {
      debugPrint('User successfully registered with backend.');
      return 'registered';
    } else if (response.statusCode == 400 &&
        response.body.contains('User already exists')) {
      debugPrint('User already exists. Proceeding as success.');
      return "login"; //Treat as success
    } else {
      debugPrint('Backend registration failed: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      return 'null';
    }
  }

  // Request additional scopes (like contacts)
  String? extractFirstContactName(Map<String, dynamic> data) {
    final connections = data['connections'] as List<dynamic>?;
    final contact = connections?.firstWhere(
      (contact) => contact['names'] != null,
      orElse: () => null,
    ) as Map<String, dynamic>?;

    if (contact != null) {
      final names = contact['names'] as List<dynamic>;
      final name = names.firstWhere(
        (name) => name['displayName'] != null,
        orElse: () => null,
      ) as Map<String, dynamic>?;

      return name?['displayName'] as String?;
    }
    return null;
  }

  Future<void>
      getServerAuthCode() async {} //Your backend can verify and fetch tokens directly from Google, ensuring better security
  Future<AuthResult?> _signInSilently() async {
    final account = await _googleSignIn.signInSilently();
    return await _handleAccount(account);
  }

  Future<AuthResult?> _signInWithPicker() async {
    final account = await _googleSignIn.signIn();
    return await _handleAccount(account);
  }

  Future<AuthResult?> _handleAccount(GoogleSignInAccount? account) async {
    currentUser = account;
    if (account == null) return null;

    final auth = await account.authentication;
    if (auth.accessToken == null) return null;

    isAuthorized = true;
    final status = await _fetchContact(auth.accessToken!);
    return AuthResult(account: account, status: status);
  }
}

class AuthResult {
  final GoogleSignInAccount account;
  final String status; // 'registered' or 'login'

  AuthResult({required this.account, required this.status});
}
