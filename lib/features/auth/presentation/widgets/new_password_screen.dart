import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/secure_storage_utils.dart';
import '../blocs/sign_in/sign_in_bloc.dart';
import 'custom_button_widget.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _obscurePassword = ValueNotifier<bool>(true);
  final _obscureConfirm = ValueNotifier<bool>(true);

  String? _email;
  String? _otp;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final session = await getIt<SecureStorageUtil>().getForgotPasswordSession();
    _email = session['email'];
    _otp = session['code'];
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    _obscurePassword.dispose();
    _obscureConfirm.dispose();
    super.dispose();
  }

  void _submit() {
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (_email == null || _otp == null) {
      _showError('Session expired. Please restart the flow.');
      return;
    }
    if (password.isEmpty || password.length < 6) {
      _showError('Password must be at least 6 characters');
      return;
    }
    if (password != confirm) {
      _showError('Passwords do not match');
      return;
    }

    context.read<SignInBloc>().add(ChangePasswordRequested(
          email: _email!,
          code: _otp!,
          newPassword: password,
        ));
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignInBloc, SignInState>(
      listener: (context, state) async {
        if (state is PasswordChangedSuccess) {
          await getIt<SecureStorageUtil>().clearForgotPasswordSession();
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password changed successfully!'),
              backgroundColor: Color(0xFF00C853),
            ),
          );
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else if (state is SignInFailure) {
          _showError(state.errorMessage);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1E3A5F)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                const Text(
                  'New Password',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A5F),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Set a strong new password for your account.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF666666),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'New Password',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E3A5F),
                  ),
                ),
                const SizedBox(height: 8),
                _PasswordField(
                  controller: _passwordController,
                  hint: 'Enter new password',
                  obscureNotifier: _obscurePassword,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Confirm Password',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E3A5F),
                  ),
                ),
                const SizedBox(height: 8),
                _PasswordField(
                  controller: _confirmController,
                  hint: 'Confirm new password',
                  obscureNotifier: _obscureConfirm,
                ),
                const SizedBox(height: 40),
                BlocBuilder<SignInBloc, SignInState>(
                  builder: (context, state) {
                    if (state is SignInLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF00C853),
                        ),
                      );
                    }
                    return CustomButton(
                      text: 'Reset Password',
                      onPressed: _submit,
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.hint,
    required this.obscureNotifier,
  });

  final TextEditingController controller;
  final String hint;
  final ValueNotifier<bool> obscureNotifier;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: obscureNotifier,
      builder: (context, obscure, _) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscure,
            style: const TextStyle(fontSize: 15, color: Color(0xFF1E3A5F)),
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.lock_outline,
                color: Color(0xFF666666),
                size: 20,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: const Color(0xFF666666),
                  size: 20,
                ),
                onPressed: () => obscureNotifier.value = !obscure,
              ),
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFF999999),
                fontSize: 15,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        );
      },
    );
  }
}
