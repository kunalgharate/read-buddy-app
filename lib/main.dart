import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection.dart';
import 'features/books/presentation/bloc/book_bloc.dart';
import 'features/books/presentation/pages/book_page.dart';
import 'sign_in.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();  // Ensures that Flutter bindings are initialized
  configureDependencies();  // Initialize all dependencies (before runApp())
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<BookBloc>()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Read Buddy",
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        // home:const BookPage(),
         home:const ReadBuddyLoginScreen(),
        routes: {
          '/book': (context) => const BookPage(),
        },
        // initialRoute: '/book', // Make sure you're navigating to the correct route
          initialRoute: '/signin',
      ),
    );
  }
}
