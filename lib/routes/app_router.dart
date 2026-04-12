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
import 'package:read_buddy_app/features/donate/presentation/pages/donate_book_form_page.dart';
import 'package:read_buddy_app/features/donate/presentation/pages/donate_money_page.dart';
import 'package:read_buddy_app/features/ebook/domain/entities/ebook.dart';
import 'package:read_buddy_app/features/ebook/presentation/pages/ebook_detail_page.dart';
import 'package:read_buddy_app/features/ebook/presentation/pages/ebook_list_page.dart';
import 'package:read_buddy_app/features/ebook/presentation/pages/epub_reader_page.dart';
import 'package:read_buddy_app/features/ebook/presentation/pages/pdf_reader_page.dart';
import 'package:read_buddy_app/features/audiobook/domain/entities/audiobook.dart';
import 'package:read_buddy_app/features/audiobook/presentation/pages/audiobook_list_page.dart';
import 'package:read_buddy_app/features/audiobook/presentation/pages/audiobook_player_page.dart';
import 'package:read_buddy_app/features/home/presentation/screens/home_screen.dart';
import 'package:read_buddy_app/features/home/presentation/widgets/Format_screen.dart';
import 'package:read_buddy_app/features/questionaries/presentations/pages/onboarding_questionaire.dart';
import 'package:read_buddy_app/features/question_crud/presentation/pages/question_list_page.dart';
import '../features/auth/presentation/widgets/email_verification_widget.dart';
import '../features/books/presentation/pages/book_page.dart';
import '../features/dashboard/presentation/screens/admin_dashboard_screen.dart';
import '../features/onboarding/onboarding_screens.dart';
import '../features/mybook/presentation/mybook.dart';
import '../features/notification/presentation/pages/notification_page.dart';
import '../features/rewards/presentation/pages/rewards_page.dart';
import '../features/search/presentation/screens/search_screen.dart';
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
      case '/book-format':
        return MaterialPageRoute(builder: (_) => const BookFormatScreen());
      case '/donate-book-form':
        return MaterialPageRoute(builder: (_) => const DonateBookFormPage());
      case '/donate-money':
        return MaterialPageRoute(builder: (_) => const DonateMoneyPage());
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
      case '/rewards':
        return MaterialPageRoute(builder: (_) => const RewardsPage());
      case '/search':
        return MaterialPageRoute(builder: (_) => const SearchScreen());
      case '/notification':
        return MaterialPageRoute(builder: (_) => const NotificationPage());
      case '/mybooks':
        return MaterialPageRoute(builder: (_) => const Mybook());
      case '/onboarding-page':
        return MaterialPageRoute(
          builder: (_) => const OnboardingQuestionnaire(),
        );
      case '/ebooks':
        return MaterialPageRoute(builder: (_) => const EBookListPage());
      case '/ebook-detail':
        final ebook = settings.arguments as EBook;
        return MaterialPageRoute(builder: (_) => EBookDetailPage(ebook: ebook));
      case '/pdf-reader':
        final args = settings.arguments as Map<String, String>;
        return MaterialPageRoute(
          builder: (_) => PdfReaderPage(
            url: args['url']!,
            title: args['title']!,
            language: args['language'] ?? 'en',
          ),
        );
      case '/epub-reader':
        final args = settings.arguments as Map<String, String>;
        return MaterialPageRoute(
          builder: (_) => EpubReaderPage(
            url: args['url']!,
            title: args['title']!,
            language: args['language'] ?? 'en',
          ),
        );
      case '/audiobooks':
        return MaterialPageRoute(
          builder: (_) => const AudioBookListPage(),
        );
      case '/audiobook-player':
        final book = settings.arguments as AudioBook;
        return MaterialPageRoute(
          builder: (_) => AudioBookPlayerPage(audioBook: book),
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
