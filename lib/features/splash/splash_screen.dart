import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/di/injection.dart';
import '../../core/utils/secure_storage_utils.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
          _checkUserSession();
    });
  }

  Future<void> _checkUserSession() async {
    final secureStorage = getIt<SecureStorageUtil>();
    final user = await secureStorage.getUser();
    final accessToken = await secureStorage.getAccessToken();
    final refreshToken = await secureStorage.getRefreshToken();

    final hasValidSession = user != null && accessToken != null &&
        refreshToken != null;


    print("user : ${user?.name} ${user?.email} ${user?.role} $accessToken $refreshToken");
    final isOnboardingCompleted = await secureStorage.getOnboardingStatus();

    if (!isOnboardingCompleted) {
      Navigator.pushReplacementNamed(context, '/onboarding');
      return;
    }
    // If user is null or accessToken is missing, treat it as not logged in
    if (user == null || accessToken == null) {
      Navigator.pushReplacementNamed(context, '/signin');
      return;
    }
    // Navigate to admin or home based on role
    if (user.role == 'admin') {
      Navigator.pushReplacementNamed(context, '/admin');
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/book_logo.png", height: 140), // <-- PNG logo here
            const SizedBox(height: 16),
            Text(
              "ReadBuddy",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
