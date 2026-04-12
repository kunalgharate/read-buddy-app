import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/splash/splash_screen.dart';
import 'package:read_buddy_app/features/auth/presentation/blocs/google_sign_in/google_sign_in_bloc.dart';
import 'package:read_buddy_app/features/auth/presentation/blocs/sign_in/sign_in_bloc.dart';
import 'package:read_buddy_app/features/auth/presentation/blocs/sign_up/sign_up_bloc.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/cubit/cubit/location_cubit.dart';
import 'package:read_buddy_app/features/banner/presentation/bloc/banner_bloc.dart';
import 'package:read_buddy_app/features/profile/presentation/blocs/profile_bloc.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/bloc/bloc/book_crud_bloc.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/cubit/cubit/user_cubit.dart';
import 'package:read_buddy_app/features/books/presentation/bloc/book_bloc.dart';
import 'package:read_buddy_app/features/category_crud/presentation/bloc/bloc/category_bloc.dart';
import 'package:read_buddy_app/features/questionaries/presentations/bloc/on_boarding_bloc.dart';
import 'core/di/injection.dart';
import 'core/services/connectivity_service.dart';
import 'core/utils/app_bloc_observer.dart';
import 'core/widgets/connectivity_wrapper.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  configureDependencies();
  await ConnectivityService.instance.init();
  Bloc.observer = AppBlocObserver();

  print('🚀 [main] App starting...');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<BookBloc>()),
        BlocProvider(create: (_) => getIt<SignInBloc>()),
        BlocProvider(create: (_) => getIt<GoogleSignInBloc>()),
        BlocProvider(create: (_) => getIt<SignUpBloc>()),
        BlocProvider(create: (_) => getIt<ProfileBloc>()),
        BlocProvider(create: (_) => getIt<BannerBloc>()),
        BlocProvider(create: (_) => getIt<CategoryBloc>()),
        BlocProvider(create: (_) => getIt<BookCrudBloc>()),
        BlocProvider(create: (_) => getIt<UserCubit>()..fetchUsers()),
        BlocProvider(create: (_) => getIt<LocationCubit>()),
        BlocProvider(create: (_) => getIt<OnboardingBloc>()),
      ],
      child: MaterialApp(
        title: 'Read Buddy',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 3, 7, 91),
          ),
          textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
          useMaterial3: true,
        ),
        home: const ConnectivityWrapper(
          child: SplashScreen(),
        ),
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
