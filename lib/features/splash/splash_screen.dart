
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:read_buddy_app/features/auth/presentation/pages/sign_in_page.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/app_preferences.dart';
import '../../../../core/utils/secure_storage_utils.dart';
import '../home/presentation/screens/home_screen.dart';
import '../onboarding/onboarding_screens.dart';
import '../questionaries/presentations/pages/onboarding_questionaire.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _animController.forward();

    // Wait for animation then check auth
    Future.delayed(const Duration(milliseconds: 2000), _checkAuth);
  }

  Future<void> _checkAuth() async {
    final hasSeen = await AppPreferences.hasSeenOnboarding();

    if (!mounted) return;

    // First time ever — show intro slides
    if (!hasSeen) {
      _navigate(const OnboardingScreen());
      return;
    }

    final isLoggedIn = await AppPreferences.isLoggedIn();

    if (!mounted) return;

    if (!isLoggedIn) {
      _navigate(const SignInScreen());
      return;
    }

    // Logged in — get saved user
    final secureStorage = getIt<SecureStorageUtil>();
    final user = await secureStorage.getUser();

    if (!mounted) return;

    if (user == null) {
      // Corrupted state — reset
      await AppPreferences.clear();
      _navigate(const SignInScreen());
      return;
    }

    // Route based on onboardingCompleted
    if (user.onboardingCompleted) {
      _navigate(const HomeScreen());
    } else {
      _navigate(const OnboardingQuestionnaire());
    }
  }

  void _navigate(Widget screen) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, __, ___) => screen,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo / Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF2CE07F),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2CE07F).withOpacity(0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  size: 52,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              // App name
              const Text(
                'ReadBuddy',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E2939),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your reading companion',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade500,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}