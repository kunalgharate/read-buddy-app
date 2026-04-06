import 'package:flutter/material.dart';
import 'package:read_buddy_app/features/auth/presentation/pages/sign_in_page.dart';
import 'package:read_buddy_app/features/auth/presentation/pages/sing_up_page.dart';
import 'package:read_buddy_app/features/auth/presentation/widgets/forget_password_page.dart';
import 'package:read_buddy_app/features/auth/presentation/widgets/new_password_screen.dart';
import 'package:read_buddy_app/features/auth/presentation/widgets/verification_otp_screen.dart';
import 'package:read_buddy_app/features/banner/presentation/pages/banner_list.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/pages/books_list_page.dart';
import 'package:read_buddy_app/features/category_crud/presentation/pages/category_list_page.dart';
import 'package:read_buddy_app/features/donate/presentation/donation_page.dart';
import 'package:read_buddy_app/features/donated_books/presentation/pages/donated_books_page.dart';
import 'package:read_buddy_app/features/home/presentation/screens/home_screen.dart';
import 'package:read_buddy_app/features/questionaries/presentations/pages/onboarding_questionaire.dart';
import 'package:read_buddy_app/features/question_crud/presentation/pages/question_list_page.dart';
import '../features/auth/presentation/widgets/email_verification_widget.dart';
import '../features/books/presentation/pages/book_page.dart';
import '../features/dashboard/presentation/screens/admin_dashboard_screen.dart';
import '../features/onboarding/onboarding_screens.dart';
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
      case '/forgot-password':
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case '/verify-otp':
        final email = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => VerifyOtpScreen(email: email),
        );
      case '/reset-password':
        return MaterialPageRoute(builder: (_) => const ResetPasswordScreen());
      case '/admin':
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
      case '/category':
        return MaterialPageRoute(builder: (_) => const CategoryListPage());
      case '/books':
        return MaterialPageRoute(builder: (_) => const BooksListPage());
      case '/questions':
        return MaterialPageRoute(builder: (_) => const QuestionListPage());
      case '/donated-books':
        return MaterialPageRoute(builder: (_) => const DonatedBooksPage());
      case '/donation':
        return MaterialPageRoute(builder: (_) => const DonationPage());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/onboarding-questionnaire':
        return MaterialPageRoute(
          builder: (_) => const OnboardingQuestionnaire(),
        );
      case '/verification':
        return MaterialPageRoute(builder: (_) => EmailVerificationScreen());
      case '/banner':
        return MaterialPageRoute(builder: (_) => const BannersList());
      case '/onboarding-page':
        return MaterialPageRoute(
          builder: (_) => const OnboardingQuestionnaire(),
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
