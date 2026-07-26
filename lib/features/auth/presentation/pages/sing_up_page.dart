import 'package:read_buddy_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/ui_utils.dart';
import '../blocs/google_sign_in/google_sign_in_bloc.dart';
import '../blocs/sign_up/sign_up_bloc.dart';
import '../widgets/custom_button_widget.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _obscurePassword = true;
  bool _emailFromGoogle = false; // Track if email was pre-filled from Google

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (value.trim().length != 10) {
      return 'Phone number must be exactly 10 digits';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
      return 'Phone number must contain only digits';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (!RegExp(r'^[\p{L}\s]+$', unicode: true).hasMatch(value.trim())) {
      return 'Name must contain only letters and spaces';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  void _handleSignUp() {
    if (_formKey.currentState!.validate()) {
      final data = {
        "name": _nameController.text.trim(),
        "email": _emailController.text.trim().toLowerCase(),
        "password": _passwordController.text,
        "phno": _phoneController.text.trim(),
        "userRole": "user",
        "picture": "",
        "deviceInfo": {
          "deviceModel": "Mobile Device",
          "deviceOS": "Mobile OS",
        },
      };
      context.read<SignUpBloc>().add(RegisterUserEvent(data));
    } else {
      UiUtils.showErrorSnackBar(
        context,
        message: 'Please fill all required fields correctly.',
      );
    }
  }

  void _handleGoogleSignUp() {
    context.read<GoogleSignInBloc>().add(const GoogleSignInRequested());
  }

  void _navigateToSignIn() {
    Navigator.pushReplacementNamed(context, '/signin');
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<SignUpBloc, SignUpState>(
          listener: (context, state) {
            if (state is SignUpSuccess) {
              UiUtils.showSuccessSnackBar(
                context,
                message: 'Registration successful! Please verify your email.',
              );
              Navigator.pushNamed(context, '/verification');
            }

            if (state is SignUpError) {
              if (state.isUserAlreadyExists) {
                UiUtils.showErrorSnackBar(
                  context,
                  message:
                      'This account already exists. Redirecting to Sign In...',
                  action: SnackBarAction(
                    label: 'Sign In',
                    textColor: Colors.white,
                    onPressed: _navigateToSignIn,
                  ),
                );
                Future.delayed(const Duration(seconds: 3), () {
                  if (mounted) _navigateToSignIn();
                });
              } else {
                UiUtils.showErrorSnackBar(
                  context,
                  message: state.message,
                );
              }
            }
          },
        ),
        BlocListener<GoogleSignInBloc, GoogleSignInState>(
          listener: (context, state) {
            if (state is GoogleSignUpDataFetched) {
              // Pre-fill form with Google account data
              setState(() {
                _nameController.text = state.name;
                _emailController.text = state.email;
                _emailFromGoogle = true;
              });
              UiUtils.showSuccessSnackBar(
                context,
                message:
                    'Google account loaded! Please set a password to continue.',
              );
            } else if (state is GoogleSignInFailure) {
              UiUtils.showErrorSnackBar(
                context,
                message: state.errorMessage,
              );
            }
          },
        ),
      ],
      child: BlocBuilder<SignUpBloc, SignUpState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),
                      Text(
                        'Create New Account',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryColor(context),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Google Sign-Up button
                      _buildGoogleSignUpButton(),
                      const SizedBox(height: 20),

                      // Divider
                      const Row(
                        children: [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'or sign up with email',
                              style: TextStyle(
                                color: AppColors.textHint,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Name
                      const Text(
                        'Name',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameController,
                        validator: _validateName,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[\p{L}\s]', unicode: true)),
                        ],
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          hintText: 'Enter Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Email
                      const Text(
                        'Email',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailController,
                        validator: _validateEmail,
                        keyboardType: TextInputType.emailAddress,
                        readOnly: _emailFromGoogle,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: _emailFromGoogle
                              ? Theme.of(context)
                                  .disabledColor
                                  .withValues(alpha: 0.1)
                              : Theme.of(context).colorScheme.surface,
                          hintText: 'Enter Email ID',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.email_outlined),
                          suffixIcon: _emailFromGoogle
                              ? const Icon(Icons.check_circle,
                                  color: AppColors.primary, size: 20)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Password
                      const Text(
                        'Password',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _passwordController,
                        validator: _validatePassword,
                        obscureText: !_obscurePassword,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          hintText: 'Set a Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.lock_outline),
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
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Phone
                      const Text(
                        'Phone Number',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _phoneController,
                        validator: _validatePhone,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          hintText: 'Enter Phone Number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.phone_outlined),
                        ),
                      ),

                      const SizedBox(height: 24),
                      CustomButton(
                        text: state is SignUpLoading
                            ? 'Creating Account...'
                            : 'Send Email Code',
                        onPressed: _handleSignUp,
                        backgroundColor: const Color(0xFF4CAF50),
                      ),

                      const SizedBox(height: 20),
                      // Already have account?
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account? ',
                            style: TextStyle(
                                color: AppColors.textHint, fontSize: 14),
                          ),
                          TextButton(
                            onPressed: _navigateToSignIn,
                            child: const Text(
                              'Sign In',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGoogleSignUpButton() {
    return BlocBuilder<GoogleSignInBloc, GoogleSignInState>(
      builder: (context, state) {
        final isLoading = state is GoogleSignInLoading;
        return SizedBox(
          width: double.infinity,
          height: 52.0,
          child: OutlinedButton.icon(
            onPressed: isLoading ? null : _handleGoogleSignUp,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.g_mobiledata_rounded,
                    size: 28, color: Color(0xFF4285F4)),
            label: Text(
              isLoading ? 'Loading...' : 'Sign up with Google',
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        );
      },
    );
  }
}
