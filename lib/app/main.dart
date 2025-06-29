import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/features/auth/domain/usecases/sign_in.dart';
import 'package:read_buddy_app/features/auth/presentation/blocs/sign_in/sign_in_bloc.dart';
import 'package:read_buddy_app/features/auth/presentation/pages/sign_in_with_google.dart';

import '../core/di/injection.dart';
import '../core/utils/app_bloc_observer.dart';
import '../features/books/presentation/bloc/book_bloc.dart';
import '../features/books/presentation/pages/book_page.dart';
import '../features/splash/splash_screen.dart';
import '../features/user_preference/presentation/screens/question_screen.dart';
import '../routes/app_router.dart';

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
      ],
      child: MaterialApp(
        title: "Read Buddy",
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        // home:
        //     const AuthStartupHandler(), //Use this for the auto log in if the User Manullay dont log out
        onGenerateRoute: AppRouter.generateRoute,
        initialRoute: '/',
      ),
    );
  }
}

//Use this for the auto log in if the User Manullay dont log out

// class AuthStartupHandler extends StatefulWidget {
//   const AuthStartupHandler({super.key});

//   @override
//   State<AuthStartupHandler> createState() => _AuthStartupHandlerState();
// }

// class _AuthStartupHandlerState extends State<AuthStartupHandler> {
//   final _auth = SignInWithGoogle();

//   @override
//   void initState() {
//     super.initState();
//     _initCheck();
//   }

//   Future<void> _initCheck() async {
//     final result = await _auth.signInRespectingLogout();

//     if (!mounted) return;

//     if (result != null) {
//       await _auth.clearLogoutFlag();
//       Navigator.pushReplacementNamed(context, '/home');
//     } else {
//       Navigator.pushReplacementNamed(context, '/login'); // 👈 Adjust if needed
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: Center(child: CircularProgressIndicator()),
//     );
//   }
// }
