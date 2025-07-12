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
  // Constants
  static const Duration _splashDuration = Duration(seconds: 2);
  static const Duration _minimumSplashTime = Duration(milliseconds: 1500);
  
  // State
  bool _isLoading = true;
  String _statusMessage = 'Loading...';

  @override
  void initState() {
    super.initState();
    // Add a small delay to ensure the widget is fully built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _initializeApp();
      });
    });
  }

  Future<void> _initializeApp() async {
    final startTime = DateTime.now();
    
    try {
      await _checkUserSession();
    } catch (e) {
      debugPrint('Splash screen error: $e');
      // Ensure minimum splash time before navigation
      final elapsedTime = DateTime.now().difference(startTime);
      if (elapsedTime < _minimumSplashTime) {
        await Future.delayed(_minimumSplashTime - elapsedTime);
      }
      _navigateToSignIn();
      return;
    }

    // Ensure minimum splash time for better UX
    final elapsedTime = DateTime.now().difference(startTime);
    if (elapsedTime < _minimumSplashTime) {
      await Future.delayed(_minimumSplashTime - elapsedTime);
    }
  }

  Future<void> _checkUserSession() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Checking session...';
        });
      }
    });

    try {
      final secureStorage = getIt<SecureStorageUtil>();
      
      // Check onboarding status first
      final isOnboardingCompleted = await secureStorage.getOnboardingStatus();
      if (!isOnboardingCompleted) {
        _navigateToOnboarding();
        return;
      }

      // Get user session data
      final sessionData = await _getSessionData(secureStorage);
      
      if (!sessionData.hasValidSession) {
        _navigateToSignIn();
        return;
      }

      // Validate token (basic validation - you might want to add API call for server validation)
      if (!_isTokenValid(sessionData.accessToken!)) {
        await _clearInvalidSession(secureStorage);
        _navigateToSignIn();
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _statusMessage = 'Welcome back, ${sessionData.user!.name}!';
          });
        }
      });

      // Navigate based on user role
      _navigateBasedOnRole(sessionData.user!.role);
      
    } catch (e) {
      debugPrint('Session check error: $e');
      _navigateToSignIn();
    }
  }

  Future<SessionData> _getSessionData(SecureStorageUtil secureStorage) async {
    // Get all session data in parallel for better performance
    final results = await Future.wait([
      secureStorage.getUser(),
      secureStorage.getAccessToken(),
      secureStorage.getRefreshToken(),
    ]);

    return SessionData(
      user: results[0] as dynamic,
      accessToken: results[1] as String?,
      refreshToken: results[2] as String?,
    );
  }

  bool _isTokenValid(String token) {
    try {
      // Basic token validation - check if it's not empty and has reasonable length
      if (token.isEmpty || token.length < 10) {
        return false;
      }

      // You can add more sophisticated validation here:
      // - JWT token expiry check
      // - Token format validation
      // - Server-side validation call
      
      return true;
    } catch (e) {
      debugPrint('Token validation error: $e');
      return false;
    }
  }

  Future<void> _clearInvalidSession(SecureStorageUtil secureStorage) async {
    try {
      await Future.wait([
        secureStorage.clearTokens(),
        secureStorage.delete(key: 'user'),
      ]);
      debugPrint('Invalid session cleared');
    } catch (e) {
      debugPrint('Error clearing session: $e');
    }
  }

  // Navigation methods
  void _navigateToOnboarding() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    });
  }

  void _navigateToSignIn() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/signin');
      }
    });
  }

  void _navigateBasedOnRole(String role) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      final route = role == 'admin' ? '/admin' : '/home';
      Navigator.pushReplacementNamed(context, route);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLogo(),
              const SizedBox(height: 16),
              _buildAppTitle(),
              const SizedBox(height: 32),
              _buildLoadingIndicator(),
              const SizedBox(height: 16),
              _buildStatusMessage(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Hero(
      tag: 'app_logo',
      child: Image.asset(
        "assets/book_logo.png",
        height: 140,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 140,
            width: 140,
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.book,
              size: 80,
              color: Colors.green[800],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppTitle() {
    return Text(
      "ReadBuddy",
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.green[800],
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return AnimatedOpacity(
      opacity: _isLoading ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green[600]!),
        ),
      ),
    );
  }

  Widget _buildStatusMessage() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        _statusMessage,
        key: ValueKey(_statusMessage),
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// Helper class for session data
class SessionData {
  final dynamic user;
  final String? accessToken;
  final String? refreshToken;

  SessionData({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  bool get hasValidSession =>
      user != null && 
      accessToken != null && 
      refreshToken != null &&
      accessToken!.isNotEmpty &&
      refreshToken!.isNotEmpty;
}
