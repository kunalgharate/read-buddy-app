// import 'dart:math';

// import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GoogleSignInService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    // serverClientId:
    //     '620497979110-rrsto8omsq5brg2c9h1h4j5phecbcrma.apps.googleusercontent.com',
  );

  Future<void> signInAndSendTokenServer() async {
    // Google cloud function logic own server with token
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) {
        print("Üser canceled sign in");
        return;
      }

      final GoogleSignInAuthentication auth = await account.authentication;
      final String? idToken = auth.idToken;
      final String? accessToken = auth.accessToken;
      print(account);
      print('ID Token: $idToken');
      print('Access Token: $accessToken');
      if (idToken != null) {
        final response = await http.post(
          Uri.parse("http://192.168.29.103:3000/api/users/verify-email"),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'idToken': idToken,
            'accessToken': accessToken,
          }),
        );

        if (response.statusCode == 200) {
          print("User verified on server");
        } else {
          print('Server rejected: ${response.body}');
        }
      } else {
        print("IdToken is invalid or null ");
      }
    } catch (e) {
      print("Google sign_in error: $e");
    }
  }
}

//   Future<void> signIn() async {
//     // Google cloud function logic with token
//     try {
//       final GoogleSignInAccount? result = await _googleSignIn.signIn();
//       if (result != null) {
//         final GoogleSignInAuthentication auth = await result.authentication;

//         final String? idToken = auth.idToken;
//         final String? accessToken = auth.accessToken;

//         print(result);
//         print('User: ${result.displayName}');
//         print('Email: ${result.email}');
//         print('ID Token: $idToken');
//         print('Access Token: $accessToken');
//       } else {
//         print('Sign-in canceled');
//       }
//     } catch (e) {
//       print('Google sign-in error: $e');
//     }
//   }
// }



  // Future<UserCredential> signInWithGoogle() async {    //FireBase sign-in logic
//   // Trigger the authentication flow
//   final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

//   // Obtain the auth details from the request
//   final GoogleSignInAuthentication? googleAuth =
//       await googleUser?.authentication;

//   // Create a new credential
//   final credential = GoogleAuthProvider.credential(
//     accessToken: googleAuth?.accessToken,
//     idToken: googleAuth?.idToken,
//   );

//   // Once signed in, return the UserCredential
//   return await FirebaseAuth.instance.signInWithCredential(credential);
// }