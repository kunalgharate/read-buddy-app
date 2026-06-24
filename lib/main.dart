import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:read_buddy_app/features/splash/splash_screen.dart';
import 'package:read_buddy_app/features/auth/presentation/blocs/google_sign_in/google_sign_in_bloc.dart';
import 'package:read_buddy_app/features/auth/presentation/blocs/sign_in/sign_in_bloc.dart';
import 'package:read_buddy_app/features/auth/presentation/blocs/sign_up/sign_up_bloc.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/cubit/cubit/location_cubit.dart';
import 'package:read_buddy_app/features/banner/presentation/bloc/banner_bloc.dart';

import 'package:read_buddy_app/features/profile/presentation/blocs/profile_bloc.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/bloc/bloc/book_crud_bloc.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/cubit/cubit/user_cubit.dart';
import 'package:read_buddy_app/features/books/presentation/bloc/book_bloc.dart';
import 'package:read_buddy_app/features/donate/presentation/bloc/donate_book_bloc.dart';
import 'package:read_buddy_app/features/donated_books/presentation/bloc/donated_books_bloc.dart';
import 'package:read_buddy_app/features/category_crud/presentation/bloc/bloc/category_bloc.dart';
import 'package:read_buddy_app/features/questionaries/presentations/bloc/on_boarding_bloc.dart';
import 'package:read_buddy_app/core/di/injection.dart';
import 'package:read_buddy_app/core/services/connectivity_service.dart';
import 'package:read_buddy_app/core/services/session_event_bus.dart';
import 'package:read_buddy_app/core/utils/app_bloc_observer.dart';
import 'package:read_buddy_app/core/widgets/connectivity_wrapper.dart';
import 'package:read_buddy_app/core/widgets/session_expired_dialog.dart';
import 'package:read_buddy_app/core/theme/theme_notifier.dart';
import 'package:read_buddy_app/routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await configureDependencies();
  await ConnectivityService.instance.init();
  await ThemeNotifier.instance.init();
  Bloc.observer = AppBlocObserver();

  print('🚀 [main] App starting...');

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  StreamSubscription<SessionEvent>? _sessionSub;

  @override
  void initState() {
    super.initState();
    _sessionSub = SessionEventBus.instance.stream.listen((event) {
      if (event == SessionEvent.sessionReplaced) {
        final ctx = _navigatorKey.currentContext;
        if (ctx != null) showSessionExpiredDialog(ctx);
      }
    });
  }

  @override
  void dispose() {
    _sessionSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<BookBloc>()),
        BlocProvider(create: (_) => getIt<DonatedBooksBloc>()),
        BlocProvider(create: (_) => getIt<SignInBloc>()),
        BlocProvider(create: (_) => getIt<GoogleSignInBloc>()),                                   BlocProvider(create: (_) => getIt<SignUpBloc>()),
        BlocProvider(create: (_) => getIt<ProfileBloc>()),
        // BlocProvider(create: (_) => getIt<HomeBloc>()),
        BlocProvider(create: (_) => getIt<BannerBloc>()),
        BlocProvider(create: (_) => getIt<CategoryBloc>()),
        BlocProvider(create: (_) => getIt<BookCrudBloc>()),
        BlocProvider(create: (_) => getIt<UserCubit>()..fetchUsers()),
        BlocProvider(create: (_) => getIt<LocationCubit>()),
        BlocProvider(create: (_) => getIt<OnboardingBloc>()),
        BlocProvider(create: (_) => getIt<DonateBookBloc>()),
      ],
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: ThemeNotifier.instance,
        builder: (context, themeMode, _) => MaterialApp(
          title: 'Read Buddy',
          debugShowCheckedModeBanner: false,
          navigatorKey: _navigatorKey,
          themeMode: themeMode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2CE07F),
              primary: const Color(0xFF2CE07F),
              secondary: const Color(0xFF1AAF5C),
              surface: Colors.white,
              onPrimary: Colors.white,
              onSurface: const Color(0xFF1E2939),
            ),
            scaffoldBackgroundColor: const Color(0xFFF9FAFB),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFF1E2939),
              elevation: 0,
            ),
            textTheme: GoogleFonts.poppinsTextTheme(),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2CE07F),
              brightness: Brightness.dark,
              primary: const Color(0xFF2CE07F),
              secondary: const Color(0xFF1AAF5C),
              surface: const Color(0xFF1E1E1E),
              onPrimary: Colors.black,
              onSurface: Colors.white,
            ),
            scaffoldBackgroundColor: const Color(0xFF121212),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E1E1E),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
            useMaterial3: true,
          ),
          home: const ConnectivityWrapper(
            child: SplashScreen(),
          ),
          onGenerateRoute: AppRouter.generateRoute,
        ),
      ),
    );
  }
}
