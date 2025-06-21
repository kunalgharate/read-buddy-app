import 'package:flutter/material.dart';
import 'package:read_buddy_app/features/auth/presentation/pages/sign_in_page.dart';
import 'package:read_buddy_app/features/auth/presentation/pages/sing_up_page.dart';
import 'package:read_buddy_app/features/home/presentation/screens/home_screen.dart';

import '../features/books/presentation/pages/book_page.dart';
import '../features/dashboard/presentation/screens/admin_dashboard_screen.dart';
import '../features/onboarding/screens/onboarding_screens.dart';
import '../features/splash/splash_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/book':
        return MaterialPageRoute(builder: (_) => const BookPage());
      case '/onboarding':
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case '/signin':
        return MaterialPageRoute(builder: (_) => const SignInScreen());
      case '/signup':
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case '/admin':
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }
}
