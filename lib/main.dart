import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/bloc/bloc/book_crud_bloc.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/cubit/cubit/user_cubit.dart';
import 'package:read_buddy_app/features/category_crud/presentation/bloc/bloc/category_bloc.dart';
import 'package:read_buddy_app/layout/bottom_nav_layout.dart';

import 'core/di/injection.dart';
import 'features/books/presentation/bloc/book_bloc.dart';
import 'features/books/presentation/pages/book_page.dart';

void main() {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensures that Flutter bindings are initialized
  configureDependencies(); // Initialize all dependencies (before runApp())
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
        BlocProvider(create: (_) => getIt<CategoryBloc>()),
        BlocProvider(create: (_) => getIt<BookCrudBloc>()),
        BlocProvider(create: (_) => getIt<UserCubit>()..fetchUsers()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,

        title: "Read Buddy",
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 3, 7, 91)),
          useMaterial3: true,
        ),
        home: BookPage(),
        routes: {
          '/layout': (context) => const BottomNavLayout(),
          //'/book': (context) => const BookPage(),
        },
        initialRoute:
            '/layout', // Make sure you're navigating to the correct route
      ),
    );
  }
}
