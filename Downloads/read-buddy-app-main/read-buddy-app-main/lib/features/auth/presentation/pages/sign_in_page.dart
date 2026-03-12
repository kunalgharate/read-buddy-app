import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/secure_storage_utils.dart';
import '../../../../core/utils/ui_utils.dart';
import '../../../onboarding/presentation/screens/onboarding_questionaire.dart';
import '../blocs/google_sign_in/google_sign_in_bloc.dart';
import '../blocs/sign_in/sign_in_bloc.dart';
import '../widgets/custom_button_widget.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // State
  bool _obscurePassword = true;

  // Constants
  static const _emailRegex = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  
  // Colors
  static const _primaryColor = Color(0xFF3182CE);
  static const _textColor = Color(0xFF1E2939);
  static const _labelColor = Color(0xFF5B6675);
  static const _hintColor = Color(0xFF8895A7);
  static const _borderColor = Color(0xFFE2E8F0);
  static const _errorColor = Color(0xFFE53E3E);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Validation methods
  String? _validateEmail(String? value) {
    if (value?.trim().isEmpty ?? true) {
      return "Please enter your email";
    }
    if (!RegExp(_emailRegex).hasMatch(value!.trim())) {
      return "Please enter a valid email address";
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value?.isEmpty ?? true) {
      return "Please enter your password";
    }
    return null;
  }

  // Event handlers
  void _handleSignIn() {
    if (_formKey.currentState!.validate()) {
      context.read<SignInBloc>().add(
        SignInRequest(
          email: _emailController.text.trim().toLowerCase(),
          password: _passwordController.text,
        ),
      );
    }
  }

  void _togglePasswordVisibility() {
    setState(() => _obscurePassword = !_obscurePassword);
  }

  // Navigation methods
  void _navigateToSignUp() => Navigator.pushReplacementNamed(context, '/signup');
  void _navigateToForgotPassword() => Navigator.pushNamed(context, '/forgot-password');

  // User handling methods
  Future<void> _handleUserSuccess(user) async {
    final secureStorage = getIt<SecureStorageUtil>();
    await secureStorage.saveUser(user);
    await secureStorage.saveTokens(
      accessToken: user.accessToken,
      refreshToken: user.refreshToken,
    );

    final route = user.role == 'admin' ? '/admin' : '/home';
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<SignInBloc, SignInState>(
          listener: (context, state) async {
            if (state is SignInSuccess) {
              UiUtils.showSuccessSnackBar(
                context,
                message: 'Welcome back, ${state.user.name}!',
              );

              final secureStorage = getIt<SecureStorageUtil>();
              await secureStorage.saveUser(state.user);
              await secureStorage.saveTokens(
                accessToken: state.user.accessToken,
                refreshToken: state.user.refreshToken,
              );

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const OnboardingQuestionScreen(),
                ),
              );
            } else if (state is SignInFailure) {
              UiUtils.showErrorSnackBar(
                context,
                message: state.errorMessage,
              );
            }
          },
        ),
        BlocListener<GoogleSignInBloc, GoogleSignInState>(
          listener: (context, state) async {
            if (state is GoogleSignInSuccess) {
              UiUtils.showSuccessSnackBar(
                context,
                message: 'Google Sign-In successful! Welcome ${state.user.name}',
              );

              final secureStorage = getIt<SecureStorageUtil>();
              await secureStorage.saveUser(state.user);
              await secureStorage.saveTokens(
                accessToken: state.user.accessToken,
                refreshToken: state.user.refreshToken,
              );

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const OnboardingQuestionScreen(),
                ),
              );
            } else if (state is GoogleSignInFailure) {
              UiUtils.showErrorSnackBar(
                context,
                message: state.errorMessage,
              );
            }
          },
        )
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
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
                        const Spacer(),
                        _buildHeader(),
                        const SizedBox(height: 40.0),
                        _buildEmailField(),
                        const SizedBox(height: 24.0),
                        _buildPasswordField(),
                        const SizedBox(height: 16.0),
                        _buildForgotPasswordLink(),
                        const SizedBox(height: 32.0),
                        _buildSignInButton(),
                        const SizedBox(height: 20.0),
                        _buildGoogleSignInButton(),
                        const Spacer(),
                        _buildSignUpPrompt(),
                        const Spacer(),
                      ],
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

  Widget _buildHeader() {
    return const Text(
      'Welcome to ReadBuddy',
      style: TextStyle(
        fontSize: 32.0,
        fontWeight: FontWeight.bold,
        color: _textColor,
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Email'),
        const SizedBox(height: 8.0),
        TextFormField(
          controller: _emailController,
          validator: _validateEmail,
          keyboardType: TextInputType.emailAddress,
          decoration: _buildInputDecoration(
            hintText: 'Enter Email ID',
            prefixIcon: Icons.email_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Password'),
        const SizedBox(height: 8.0),
        TextFormField(
          controller: _passwordController,
          validator: _validatePassword,
          obscureText: _obscurePassword,
          decoration: _buildInputDecoration(
            hintText: 'Enter Password',
            prefixIcon: Icons.lock_outline,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: _labelColor,
              ),
              onPressed: _togglePasswordVisibility,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.w500,
        color: _labelColor,
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: _hintColor, fontSize: 18.0),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      prefixIcon: Icon(prefixIcon, color: _labelColor),
      suffixIcon: suffixIcon,
      border: _buildOutlineInputBorder(_borderColor),
      enabledBorder: _buildOutlineInputBorder(_borderColor),
      focusedBorder: _buildOutlineInputBorder(_primaryColor, width: 2.0),
      errorBorder: _buildOutlineInputBorder(_errorColor),
    );
  }

  OutlineInputBorder _buildOutlineInputBorder(Color color, {double width = 1.0}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  Widget _buildForgotPasswordLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: _navigateToForgotPassword,
        child: const Text(
          'Forgot Password?',
          style: TextStyle(
            color: _primaryColor,
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSignInButton() {
    return BlocBuilder<SignInBloc, SignInState>(
      builder: (context, state) {
        final isLoading = state is SignInLoading;
        return SizedBox(
          width: double.infinity,
          height: 56.0,
          child: ElevatedButton(
            onPressed: isLoading ? null : _handleSignIn,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              elevation: 0,
            ),
            child: isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Sign In',
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildGoogleSignInButton() {
    return BlocBuilder<GoogleSignInBloc, GoogleSignInState>(
      builder: (context, state) {
        if (state is GoogleSignInLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return CustomButton(
          text: 'Sign In with Google',
          width: double.infinity,
          fontSize: 18.0,
          fontWeight: FontWeight.w500,
          backgroundColor: Colors.grey.shade200,
          textColor: _textColor,
          icon: _buildGoogleIcon(),
          onPressed: () => context.read<GoogleSignInBloc>().add(GoogleSignInRequested()),
        );
      },
    );
  }

  Widget _buildGoogleIcon() {
    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black),
      alignment: Alignment.center,
      child: const Text(
        'G',
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSignUpPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account? ",
          style: TextStyle(color: _hintColor, fontSize: 16.0),
        ),
        TextButton(
          onPressed: _navigateToSignUp,
          child: const Text(
            'Sign Up',
            style: TextStyle(
              color: _primaryColor,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
