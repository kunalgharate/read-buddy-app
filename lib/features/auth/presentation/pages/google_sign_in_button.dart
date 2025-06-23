// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import '../blocs/sign_in/sign_in_bloc.dart';

// class GoogleSignInButton extends StatefulWidget {
//   const GoogleSignInButton({Key? key}) : super(key: key);

//   @override
//   _GoogleSignInButtonState createState() => _GoogleSignInButtonState();
// }

// class _GoogleSignInButtonState extends State<GoogleSignInButton> {
//   final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

//   bool _isSigningIn = false;

//   Future<void> _handleGoogleSignIn() async {
//     setState(() {
//       _isSigningIn = true;
//     });

//     try {
//       final account = await _googleSignIn.signIn();
//       if (account == null) {
//         // User cancelled the sign-in
//         setState(() {
//           _isSigningIn = false;
//         });
//         return;
//       }
//       final authentication = await account.authentication;
//       final idToken = authentication.idToken;

//       if (idToken != null) {
//         // Dispatch the GoogleSignInRequest event with the idToken
//         context.read<SignInBloc>().add(GoogleSignInRequest(idToken: idToken));
//       } else {
//         // Handle missing idToken error
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Failed to get Google ID token')),
//         );
//       }
//     } catch (error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Google Sign-In error: \$error')),
//       );
//     } finally {
//       setState(() {
//         _isSigningIn = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton.icon(
//       icon: Image.asset(
//         'assets/icons/google_logo.png',
//         height: 24,
//         width: 24,
//       ),
//       label: _isSigningIn
//           ? const SizedBox(
//               width: 16,
//               height: 16,
//               child: CircularProgressIndicator(strokeWidth: 2),
//             )
//           : const Text('Sign in with Google'),
//       onPressed: _isSigningIn ? null : _handleGoogleSignIn,
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         minimumSize: const Size(double.infinity, 50),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../blocs/sign_in/sign_in_bloc.dart';

class GoogleSignInButton extends StatefulWidget {
  const GoogleSignInButton({Key? key}) : super(key: key);

  @override
  _GoogleSignInButtonState createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  //uncomment on real
  // final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  bool _isSigningIn = false;

  Future<void> handleGoogleSignIn() async {
    setState(() {
      _isSigningIn = true;
    });

    try {
      // ✅ MOCK SIGN-IN LOGIC FOR DEMO PURPOSES
      const String name = "John Doe";
      const String email = "johndoe@gmail.com";
      const String photoUrl = "https://randomuser.me/api/portraits/men/1.jpg";

      await Future.delayed(const Duration(seconds: 1)); // simulate loading

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              CircleAvatar(backgroundImage: NetworkImage(photoUrl)),
              const SizedBox(width: 12),
              Expanded(child: Text("Name: $name\nEmail: $email")),
            ],
          ),
          duration: const Duration(seconds: 4),
        ),
      );

      //REPLACE THIS MOCK CODE WITH REAL SIGN-IN WHEN BACKEND IS READY
      /*
    final account = await _googleSignIn.signIn();
    if (account == null) {
      // User cancelled the sign-in
      return;
    }

    final GoogleSignInAuthentication auth = await account.authentication;
    final idToken = auth.idToken;

    if (idToken != null) {
      context.read<SignInBloc>().add(GoogleSignInRequest(idToken: idToken));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to get Google ID token')),
      );
    }
    */
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mock Google Sign-In error: $error')),
      );
    } finally {
      setState(() {
        _isSigningIn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Image.asset(
        'assets/icons/google_logo.png',
        height: 24,
        width: 24,
      ),
      label: _isSigningIn
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text('Sign in with Google'),
      onPressed: _isSigningIn ? null : handleGoogleSignIn,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
