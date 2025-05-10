import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection.dart';
import 'features/books/presentation/bloc/book_bloc.dart';
import 'features/books/presentation/pages/book_page.dart';




void main() {
  WidgetsFlutterBinding.ensureInitialized();  // Ensures that Flutter bindings are initialized
  configureDependencies();  // Initialize all dependencies (before runApp())
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
      ],
      child: MaterialApp(
        title: "Read Buddy",
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home:BookPage(),
        routes: {
          '/book': (context) => const BookPage(),
        },
        initialRoute: '/book', // Make sure you're navigating to the correct route
      ),
    );
  }
}
