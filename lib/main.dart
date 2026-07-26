import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:read_buddy_app/core/config/app_config.dart';
import 'package:read_buddy_app/core/config/dev_config.dart';
import 'package:read_buddy_app/features/audiobook/presentation/widgets/mini_audio_player.dart';
import 'package:read_buddy_app/features/splash/splash_screen.dart';
import 'package:read_buddy_app/features/auth/presentation/blocs/google_sign_in/google_sign_in_bloc.dart';
import 'package:read_buddy_app/features/auth/presentation/blocs/sign_in/sign_in_bloc.dart';
import 'package:read_buddy_app/features/auth/presentation/blocs/sign_up/sign_up_bloc.dart';
import 'package:read_buddy_app/features/profile/presentation/blocs/profile_bloc.dart';
import 'package:read_buddy_app/features/books/presentation/bloc/book_bloc.dart';
import 'package:read_buddy_app/features/donated_books/presentation/bloc/donated_books_bloc.dart';
import 'package:read_buddy_app/features/category_crud/presentation/bloc/bloc/category_bloc.dart';
import 'package:read_buddy_app/core/di/injection.dart';
import 'package:read_buddy_app/core/services/connectivity_service.dart';
import 'package:read_buddy_app/core/services/session_event_bus.dart';
import 'package:read_buddy_app/core/utils/app_bloc_observer.dart';
import 'package:read_buddy_app/core/widgets/connectivity_wrapper.dart';
import 'package:read_buddy_app/core/widgets/session_expired_dialog.dart';
import 'package:read_buddy_app/core/theme/theme_notifier.dart';
import 'package:read_buddy_app/core/theme/app_colors.dart';
import 'package:read_buddy_app/routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Default to dev if main.dart is called directly (e.g., flutter run without flavor)
  try {
    AppConfig.instance;
  } catch (_) {
    AppConfig.init(
      environment: Environment.dev,
      baseUrl: DevConfig.baseUrl,
      appName: DevConfig.appName,
    );
  }

  await configureDependencies();
  await ConnectivityService.instance.init();
  await ThemeNotifier.instance.init();
  Bloc.observer = AppBlocObserver();

  print('🚀 [main] App starting... (${AppConfig.instance.environment.name})');

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
        if (!mounted) return;
        final ctx = _navigatorKey.currentContext;
        if (ctx != null) {
          showSessionExpiredDialog(
              ctx); // ignore: use_build_context_synchronously
        } else {
          // Fallback: navigate after a short delay if context not ready
          Future.delayed(const Duration(milliseconds: 500), () {
            if (!mounted) return;
            final delayedCtx = _navigatorKey.currentContext;
            if (delayedCtx != null) {
              showSessionExpiredDialog(
                  delayedCtx); // ignore: use_build_context_synchronously
            }
          });
        }
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
        // Auth — needed immediately for login/signup flow
        BlocProvider(create: (_) => getIt<SignInBloc>()),
        BlocProvider(create: (_) => getIt<GoogleSignInBloc>()),
        BlocProvider(create: (_) => getIt<SignUpBloc>()),
        // Profile — needed across splash, home, profile, book detail
        BlocProvider(create: (_) => getIt<ProfileBloc>()),
        // Books — singleton used across multiple screens
        BlocProvider(create: (_) => getIt<BookBloc>()),
        BlocProvider(create: (_) => getIt<DonatedBooksBloc>()),
        // Categories — singleton used in home, donate, bookcrud
        BlocProvider(create: (_) => getIt<CategoryBloc>()),
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
              seedColor: AppColors.primary,
              primary: AppColors.primary,
              secondary: AppColors.secondary,
              surface: AppColors.surface,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
            scaffoldBackgroundColor: AppColors.background,
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.textPrimary,
              elevation: 0,
            ),
            textTheme: GoogleFonts.poppinsTextTheme(),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              brightness: Brightness.dark,
              primary: AppColors.primary,
              secondary: AppColors.secondary,
              surface: AppColors.surfaceDark,
              onPrimary: Colors.black,
              onSurface: AppColors.textPrimaryDark,
            ),
            scaffoldBackgroundColor: AppColors.backgroundDark,
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.surfaceDark,
              foregroundColor: AppColors.textPrimaryDark,
              elevation: 0,
            ),
            cardTheme: CardThemeData(
              color: AppColors.cardDark,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.borderDark),
              ),
            ),
            dividerTheme: const DividerThemeData(
              color: AppColors.dividerDark,
              thickness: 1,
            ),
            listTileTheme: const ListTileThemeData(
              textColor: AppColors.textPrimaryDark,
              iconColor: AppColors.textSecondaryDark,
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: AppColors.cardDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.borderDark),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.borderDark),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 2),
              ),
              labelStyle: const TextStyle(color: AppColors.textSecondaryDark),
              hintStyle: const TextStyle(color: AppColors.textMutedDark),
            ),
            chipTheme: ChipThemeData(
              backgroundColor: AppColors.cardDark,
              labelStyle: const TextStyle(color: AppColors.textPrimaryDark),
              side: const BorderSide(color: AppColors.borderDark),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
            useMaterial3: true,
          ),
          home: const ConnectivityWrapper(
            child: SplashScreen(),
          ),
          onGenerateRoute: AppRouter.generateRoute,
          builder: (context, child) {
            return Material(
              child: Stack(
                children: [
                  Positioned.fill(child: child ?? const SizedBox.shrink()),
                  const Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: SafeArea(
                      top: false,
                      child: MiniAudioPlayer(),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
