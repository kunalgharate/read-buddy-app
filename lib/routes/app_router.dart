import 'package:flutter/material.dart';
import 'package:read_buddy_app/features/auth/presentation/pages/sign_in_page.dart';
import 'package:read_buddy_app/features/auth/presentation/pages/sing_up_page.dart';
import 'package:read_buddy_app/features/auth/presentation/widgets/forget_password_page.dart';
import 'package:read_buddy_app/features/auth/presentation/widgets/new_password_screen.dart';
import 'package:read_buddy_app/features/auth/presentation/widgets/verification_otp_screen.dart';
import 'package:read_buddy_app/features/banner/presentation/pages/banner_list.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/pages/books_list_page.dart';
import 'package:read_buddy_app/features/category_crud/presentation/pages/category_list_page.dart';
import 'package:read_buddy_app/features/donate/presentation/pages/book_donation_page.dart';
import 'package:read_buddy_app/features/donated_books/domain/entities/donated_books_entity.dart';
import 'package:read_buddy_app/features/donated_books/presentation/pages/donated_book_detail_page.dart';
import 'package:read_buddy_app/features/donated_books/presentation/pages/donated_books_page.dart';

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

import 'package:read_buddy_app/features/questionaries/presentations/pages/onboarding_questionaire.dart';
import 'package:read_buddy_app/features/question_crud/presentation/pages/question_list_page.dart';
import 'package:read_buddy_app/features/auth/presentation/widgets/email_verification_widget.dart';
import 'package:read_buddy_app/features/book_request/presentation/pages/admin_book_requests_page.dart';
import 'package:read_buddy_app/features/book_request/presentation/pages/admin_upcoming_pickups_page.dart';
import 'package:read_buddy_app/features/books/presentation/pages/book_page.dart';
import 'package:read_buddy_app/features/dashboard/presentation/screens/admin_dashboard_screen.dart';
import 'package:read_buddy_app/features/dashboard/presentation/screens/admin_donations_page.dart';
import 'package:read_buddy_app/features/dashboard/presentation/screens/admin_donation_detail_page.dart';
import 'package:read_buddy_app/features/onboarding/onboarding_screens.dart';
import 'package:read_buddy_app/features/mybook/presentation/mybook.dart';
import 'package:read_buddy_app/features/notification/presentation/pages/notification_page.dart';
import 'package:read_buddy_app/features/rewards/presentation/pages/rewards_page.dart';
import 'package:read_buddy_app/features/search/presentation/screens/search_screen.dart';
import 'package:read_buddy_app/features/settings/settings_screen.dart';
import 'package:read_buddy_app/features/settings/address_management_screen.dart';
import 'package:read_buddy_app/features/splash/splash_screen.dart';
import 'package:read_buddy_app/features/bookcrud/data/model/book_crud_model.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/pages/Add/manage_book_variants_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/admin-book-requests':
        return MaterialPageRoute(builder: (_) => const AdminBookRequestsPage());
      case '/admin-upcoming-pickups':
        return MaterialPageRoute(
            builder: (_) => const AdminUpcomingPickupsPage());
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
      case '/admin-donations':
        return MaterialPageRoute(builder: (_) => const AdminDonationsPage());
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
      // case '/book-format':
      //   return MaterialPageRoute(builder: (_) => const BookFormatScreen());
      // case '/donate-book-form':
      //   return MaterialPageRoute(
      //       builder: (_) => const donate_form.DonationPage());
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
      case '/book-variants':
        final book = settings.arguments as BookCrudModel;
        return MaterialPageRoute(
          builder: (_) => ManageBookVariantsPage(bookCrudModel: book),
        );
      case '/banner':
        return MaterialPageRoute(builder: (_) => const BannersList());
      case '/rewards':
        return MaterialPageRoute(builder: (_) => const RewardsPage());
      case '/search':
        return MaterialPageRoute(builder: (_) => const SearchScreen());
      case '/notification':
        return MaterialPageRoute(builder: (_) => const NotificationPage());
      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case '/addresses':
        return MaterialPageRoute(builder: (_) => const AddressManagementScreen());
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
      case '/donated-book-detail':
        final book = settings.arguments as DonatedBooksEntity;
        return MaterialPageRoute(
          builder: (_) => DonatedBookDetailPage(book: book),
        );
      case '/admin-donated-book-detail':
        final book = settings.arguments as DonatedBooksEntity;
        return MaterialPageRoute(
          builder: (_) => AdminDonationDetailPage(book: book),
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
