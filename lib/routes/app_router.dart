import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/core/di/injection.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/bloc/bloc/book_crud_bloc.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/cubit/cubit/user_cubit.dart';
import 'package:read_buddy_app/features/settings/change_password_screen.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/cubit/cubit/location_cubit.dart';
import 'package:read_buddy_app/features/donate/presentation/bloc/donate_book_bloc.dart';
import 'package:read_buddy_app/features/questionaries/presentations/bloc/on_boarding_bloc.dart';
import 'package:read_buddy_app/features/library/presentation/pages/library_list_page.dart';
import 'package:read_buddy_app/features/library/presentation/pages/create_library_page.dart';
import 'package:read_buddy_app/features/library/presentation/pages/library_detail_page.dart';
import 'package:read_buddy_app/features/library/presentation/pages/assign_librarian_page.dart';
import 'package:read_buddy_app/features/library/domain/entities/library_entity.dart';
import 'package:read_buddy_app/features/address/presentation/pages/address_management_page.dart';
import 'package:read_buddy_app/features/librarian/presentation/pages/librarian_dashboard_screen.dart';
import 'package:read_buddy_app/features/librarian/presentation/pages/librarian_requests_page.dart';
import 'package:read_buddy_app/features/librarian/presentation/pages/librarian_donations_page.dart';
import 'package:read_buddy_app/features/book_request/presentation/pages/my_requests_page.dart';
import 'package:read_buddy_app/features/auth/presentation/pages/sign_in_page.dart';
import 'package:read_buddy_app/features/auth/presentation/pages/sing_up_page.dart';
import 'package:read_buddy_app/features/auth/presentation/widgets/forget_password_page.dart';
import 'package:read_buddy_app/features/auth/presentation/widgets/new_password_screen.dart';
import 'package:read_buddy_app/features/auth/presentation/widgets/verification_otp_screen.dart';
import 'package:read_buddy_app/features/banner/presentation/pages/banner_list.dart';
import 'package:read_buddy_app/features/banner/presentation/bloc/banner_bloc.dart';
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
import 'package:read_buddy_app/features/videobook/presentation/pages/videobook_player_page.dart';
import 'package:read_buddy_app/features/bookcrud/domain/entities/book_variant_entity.dart';
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
import 'package:read_buddy_app/features/dashboard/presentation/pages/admin_users_page.dart';
import 'package:read_buddy_app/features/onboarding/onboarding_screens.dart';
import 'package:read_buddy_app/features/mybook/presentation/mybook.dart';
import 'package:read_buddy_app/features/notification/presentation/pages/notification_page.dart';
import 'package:read_buddy_app/features/rewards/presentation/pages/rewards_page.dart';
import 'package:read_buddy_app/features/search/presentation/screens/search_screen.dart';
import 'package:read_buddy_app/features/settings/settings_screen.dart';
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
      case '/change-password':
        return MaterialPageRoute(builder: (_) => const ChangePasswordScreen());
      case '/admin':
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
      case '/admin-users':
        return MaterialPageRoute(builder: (_) => const AdminUsersPage());
      case '/admin-donations':
        return MaterialPageRoute(builder: (_) => const AdminDonationsPage());
      case '/category':
        return MaterialPageRoute(builder: (_) => const CategoryListPage());
      case '/books':
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => getIt<BookCrudBloc>()),
              BlocProvider(create: (_) => getIt<UserCubit>()),
              BlocProvider(create: (_) => getIt<LocationCubit>()),
            ],
            child: const BooksListPage(),
          ),
        );
      case '/questions':
        return MaterialPageRoute(builder: (_) => const QuestionListPage());
      case '/donated-books':
        return MaterialPageRoute(builder: (_) => const DonatedBooksPage());
      case '/donation':
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<DonateBookBloc>(),
            child: const DonationPage(),
          ),
        );
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
          builder: (_) => BlocProvider(
            create: (_) => getIt<OnboardingBloc>(),
            child: const OnboardingQuestionnaire(),
          ),
        );
      case '/verification':
        return MaterialPageRoute(builder: (_) => EmailVerificationScreen());
      case '/book-variants':
        final book = settings.arguments as BookCrudModel;
        return MaterialPageRoute(
          builder: (_) => ManageBookVariantsPage(bookCrudModel: book),
        );
      case '/banner':
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<BannerBloc>(),
            child: const BannersList(),
          ),
        );
      case '/libraries':
        return MaterialPageRoute(builder: (_) => const LibraryListPage());
      case '/library/create':
        final existing = settings.arguments as LibraryEntity?;
        return MaterialPageRoute(
          builder: (_) => CreateLibraryPage(existing: existing),
        );
      case '/library/detail':
        final library = settings.arguments as LibraryEntity;
        return MaterialPageRoute(
          builder: (_) => LibraryDetailPage(library: library),
        );
      case '/assign-librarian':
        return MaterialPageRoute(
          builder: (_) => const AssignLibrarianPage(),
        );
      case '/addresses':
        return MaterialPageRoute(
          builder: (_) => const AddressManagementPage(),
        );
      case '/librarian/dashboard':
        return MaterialPageRoute(
          builder: (_) => const LibrarianDashboardScreen(),
        );
      case '/librarian/requests':
        return MaterialPageRoute(
          builder: (_) => const LibrarianRequestsPage(),
        );
      case '/librarian/donations':
        return MaterialPageRoute(
          builder: (_) => const LibrarianDonationsPage(),
        );
      case '/my-requests':
        return MaterialPageRoute(
          builder: (_) => const MyRequestsPage(),
        );
      case '/rewards':
        return MaterialPageRoute(builder: (_) => const RewardsPage());
      case '/search':
        return MaterialPageRoute(builder: (_) => const SearchScreen());
      case '/notification':
        return MaterialPageRoute(builder: (_) => const NotificationPage());
      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
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
      case '/videobook-player':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => VideobookPlayerPage(
            bookTitle: args['bookTitle'] as String,
            parts: args['parts'] as List<MediaPartEntity>,
          ),
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
