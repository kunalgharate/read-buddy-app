import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/features/auth/presentation/pages/sign_in_page.dart';
import 'package:read_buddy_app/features/auth/presentation/pages/sing_up_page.dart';
import 'package:read_buddy_app/features/banner/presentation/pages/banner.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/pages/books_list_page.dart';
import 'package:read_buddy_app/features/category_crud/presentation/pages/category_list_page.dart';
import 'package:read_buddy_app/features/donate/presentation/donation_page.dart';
import 'package:read_buddy_app/features/home/presentation/screens/home_screen.dart';
import 'package:read_buddy_app/features/permissions/presentation/pages/permission_page.dart';
import 'package:read_buddy_app/core/di/injection.dart';
import 'package:read_buddy_app/features/permissions/presentation/bloc/permission_bloc.dart';

import '../features/auth/presentation/widgets/email_verification_widget.dart';
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
      case '/category':
        return MaterialPageRoute(builder: (_) => const CategoryListPage());
      case '/books':
        return MaterialPageRoute(builder: (_) => const BooksListPage());
      case '/donation':
        return MaterialPageRoute(builder: (_) => const DonationPage());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/verification':
        return MaterialPageRoute(builder: (_) => EmailVerificationScreen());
      case '/banner':
        return MaterialPageRoute(builder: (_) => const BannerScreen());
      case '/permissions':
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<PermissionBloc>(),
            child: const PermissionPage(),
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }
}
