import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/features/auth/domain/usecases/sign_in.dart';
import 'package:read_buddy_app/features/auth/presentation/blocs/sign_in/sign_in_bloc.dart';

import 'core/di/injection.dart';
import 'core/utils/app_bloc_observer.dart';
import 'features/books/presentation/bloc/book_bloc.dart';
import 'features/books/presentation/pages/book_page.dart';




void main() {
  WidgetsFlutterBinding.ensureInitialized();  // Ensures that Flutter bindings are initialized
  configureDependencies();
  Bloc.observer = AppBlocObserver();// Initialize all dependencies (before runApp())
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
      ],
      child: MaterialApp(
        title: "Read Buddy",
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home:const BookPage(),
        routes: {
          '/book': (context) => const BookPage(),
        },
        initialRoute: '/book', // Make sure you're navigating to the correct route
      ),
    );
  }
}
