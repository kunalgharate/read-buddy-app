import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/core/utils/ui_utils.dart';
import 'package:read_buddy_app/features/auth/presentation/blocs/sign_in/sign_in_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/secure_storage_utils.dart';
import '../blocs/google_sign_in/google_sign_in_bloc.dart';
import '../widgets/custom_text_button_widget.dart';
import 'forget_password_page.dart';
import 'sing_up_page.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter your email";
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
      return "Please enter a valid email address";
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your password";
    }
    return null;
  }

  void _handleSignIn() {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim().toLowerCase();
      final password = _passwordController.text;

      context.read<SignInBloc>().add(
            SignInRequest(email: email, password: password),
          );
    }
  }

  void _navigateToSignUp() {
    Navigator.pushReplacementNamed(context, '/signup');
  }

  void _navigateToForgotPassword() {
    Navigator.pushNamed(context, '/forgot-password');
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignInBloc, SignInState>(
      listener: (context, state) async {
        if (state is SignInSuccess) {
          final secureStorage = getIt<SecureStorageUtil>();
          await secureStorage.saveUser(state.user);
          await secureStorage.saveTokens(
            accessToken: state.user.accessToken,
            refreshToken: state.user.refreshToken,
          );

          UiUtils.showSuccessSnackBar(
            context,
            message: 'Welcome back, ${state.user.name}!',
          );

          // Navigate based on user role
          if (state.user.role == 'admin') {
            Navigator.pushReplacementNamed(context, '/admin');
          } else {
            Navigator.pushReplacementNamed(context, '/home');
          }
        } else if (state is SignInFailure) {
          UiUtils.showErrorSnackBar(
            context,
            message: state.errorMessage,
          );
        }
      },
      child: Scaffold(
        body: Container(
          color: Colors.white,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top,
                  ),
                  child: IntrinsicHeight(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Spacer(flex: 1),
                          const Text(
                            'Welcome to ReadBuddy',
                            style: TextStyle(
                              fontSize: 32.0,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E2939),
                            ),
                          ),
                          const SizedBox(height: 40.0),

                          // Email Field
                          const Text(
                            'Email',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF5B6675),
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          TextFormField(
                            controller: _emailController,
                            validator: _validateEmail,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'Enter Email ID',
                              hintStyle: const TextStyle(
                                color: Color(0xFF8895A7),
                                fontSize: 18.0,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                                vertical: 16.0,
                              ),
                              prefixIcon: const Icon(
                                Icons.email_outlined,
                                color: Color(0xFF5B6675),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: const BorderSide(
                                  color: Color(0xFF3182CE),
                                  width: 2.0,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE53E3E),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12.0),

                          // Password Field
                          const Text(
                            'Password',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF5B6675),
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          TextFormField(
                            controller: _passwordController,
                            validator: _validatePassword,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: 'Enter Password',
                              hintStyle: const TextStyle(
                                color: Color(0xFF8895A7),
                                fontSize: 18.0,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                                vertical: 16.0,
                              ),
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: Color(0xFF5B6675),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: const Color(0xFF5B6675),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: const BorderSide(
                                  color: Color(0xFF3182CE),
                                  width: 2.0,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE53E3E),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16.0),

                          // Forgot Password Link
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _navigateToForgotPassword,
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: Color(0xFF3182CE),
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32.0),

                          // Sign In Button
                          BlocBuilder<SignInBloc, SignInState>(
                            builder: (context, state) {
                              return SizedBox(
                                width: double.infinity,
                                height: 56.0,
                                child: ElevatedButton(
                                  onPressed: state is SignInLoading
                                      ? null
                                      : _handleSignIn,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF3182CE),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: state is SignInLoading
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          ),
                                        )
                                      : const Text(
                                          'Sign In',
                                          style: TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              );
                            },
                          ),
                          const Spacer(flex: 2),

                          // Sign Up Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don't have an account? ",
                                style: TextStyle(
                                  color: Color(0xFF8895A7),
                                  fontSize: 16.0,
                                ),
                              ),
                              TextButton(
                                onPressed: _navigateToSignUp,
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    color: Color(0xFF3182CE),
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8.0),
                          BlocListener<GoogleSignInBloc, GoogleSignInState>(
                            listener: (context, state) {
                              if (state is GoogleSignInLoading) {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) => const Center(
                                      child: CircularProgressIndicator()),
                                );
                              } else {
                                Navigator.of(context).pop();
                              }

                              if (state is GoogleSignInSuccess) {
                                // Go to the home screen
                                Navigator.pushReplacementNamed(
                                    context, '/home');
                              }
                              if (state is GoogleSignInFailure) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(state.errorMessage)));
                              }
                            },
                            child: CustomButton(
                                width: double.infinity,
                                fontSize: 18.0,
                                fontWeight: FontWeight.w500,
                                backgroundColor: Colors.black.withOpacity(0.8),
                                textColor: const Color(0xFF1E2939),
                                icon: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'G',
                                    style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white),
                                  ),
                                ),
                                text: "Sign In With Google ",
                                onPressed: () async {
                                  context
                                      .read<GoogleSignInBloc>()
                                      .add(GoogleSignInRequested());
                                }),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
