import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/core/utils/secure_storage_utils.dart';
import 'package:read_buddy_app/features/auth/domain/usecases/sign_in.dart';
import 'package:read_buddy_app/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:read_buddy_app/features/auth/presentation/blocs/google_sign_in/google_sign_in_bloc.dart';
import 'package:read_buddy_app/features/auth/presentation/blocs/sign_in/sign_in_bloc.dart';
import 'package:read_buddy_app/features/auth/presentation/blocs/sign_up/sign_up_bloc.dart';

import 'core/di/injection.dart';
import 'core/utils/app_bloc_observer.dart';
import 'features/bookcrud/presentation/bloc/bloc/book_crud_bloc.dart';
import 'features/bookcrud/presentation/cubit/cubit/user_cubit.dart';
import 'features/books/presentation/bloc/book_bloc.dart';
import 'features/books/presentation/pages/book_page.dart';
import 'features/category_crud/presentation/bloc/bloc/category_bloc.dart';
import 'features/splash/splash_screen.dart';
import 'features/user_preference/presentation/screens/question_screen.dart';
import 'routes/app_router.dart';

void main() {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensures that Flutter bindings are initialized
  configureDependencies();
  Bloc.observer =
      AppBlocObserver(); // Initialize all dependencies (before runApp())
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<BookBloc>()),
        BlocProvider(create: (_) => getIt<SignInBloc>()),
        BlocProvider(create: (_) => getIt<SignUpBloc>()),
        BlocProvider(create: (_) => getIt<BookBloc>()),
        BlocProvider(create: (_) => getIt<CategoryBloc>()),
        BlocProvider(create: (_) => getIt<BookCrudBloc>()),
        BlocProvider(create: (_) => getIt<UserCubit>()..fetchUsers()),
        BlocProvider(create: (_) => getIt<GoogleSignInBloc>()),

      ],
      child: MaterialApp(
        title: "Read Buddy",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 3, 7, 91)),
          useMaterial3: true,
        ),
        home: FutureBuilder<String?>(
          future: SecureStorageUtil().getAccessToken(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return const BookPage(); // User is logged in
            } else {
              return const SplashScreen(); // User is logged out
            }
          },
        ),
        onGenerateRoute: AppRouter.generateRoute,
        initialRoute: '/',
      ),
    );
  }
}
