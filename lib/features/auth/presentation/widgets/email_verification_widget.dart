import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/app_preferences.dart';
import '../../../../core/utils/secure_storage_utils.dart';
import '../blocs/sign_up/sign_up_bloc.dart';
import 'custom_button_widget.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String? email;
  const EmailVerificationScreen({super.key, this.email});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());

  static const int _resendCooldownSeconds = 60;
  int _resendCooldown = _resendCooldownSeconds;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _startResendCooldown();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startResendCooldown() {
    _resendTimer?.cancel();
    _resendCooldown = _resendCooldownSeconds;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_resendCooldown <= 1) {
        timer.cancel();
        setState(() => _resendCooldown = 0);
      } else {
        setState(() => _resendCooldown--);
      }
    });
  }

  Widget _buildCodeBox(int index, BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: SizedBox(
          height: 56,
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2C3E50),
            ),
            decoration: InputDecoration(
              counterText: "",
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFD6D6D6),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF2C3E50),
                  width: 2,
                ),
              ),
            ),
            onChanged: (value) {
              if (value.isNotEmpty && index < _focusNodes.length - 1) {
                _focusNodes[index + 1].requestFocus();
              } else if (value.isEmpty && index > 0) {
                _focusNodes[index - 1].requestFocus();
              }
            },
          ),
        ),
      ),
    );
  }

  void _verifyOTP(BuildContext context, String email) {
    final otp = _controllers.map((c) => c.text).join();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter complete 6-digit code'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    BlocProvider.of<SignUpBloc>(context).add(VerifyEmailEvent(email, otp));
  }

  void _resendCode(
    BuildContext context,
    String email,
  ) {
    if (_resendCooldown > 0) return;
    _startResendCooldown();
    BlocProvider.of<SignUpBloc>(context)
        .add(ResendVerificationEmailEvent(email));
  }

  Widget _buildOtpScreen(BuildContext context, String displayEmail) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0B2545)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Verification Email',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0B2545),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Please enter the code we just sent to',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                color: Color(0xFF2E2E2E),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              displayEmail,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: List.generate(
                  6, (index) => _buildCodeBox(index, context)),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: _resendCooldown > 0
                  ? null
                  : () {
                      _resendCode(context, displayEmail);
                    },
              child: Text.rich(
                TextSpan(
                  text: 'If you did not receive code? ',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                  children: [
                    TextSpan(
                      text: _resendCooldown > 0
                          ? 'Resend in ${_resendCooldown}s'
                          : 'Resend',
                      style: TextStyle(
                        fontSize: 18,
                        color: _resendCooldown > 0
                            ? Colors.grey
                            : const Color(0xFF0B2545),
                        fontWeight: FontWeight.bold,
                        decoration: _resendCooldown > 0
                            ? TextDecoration.none
                            : TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),
            CustomButton(
              text: 'Continue',
              onPressed: () => _verifyOTP(context, displayEmail),
              backgroundColor: const Color(0xFF00C853),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignUpBloc, SignUpState>(
      listener: (context, state) async {
        if (state is SignUpUserVerified) {
          final secureStorage = getIt<SecureStorageUtil>();
          await secureStorage.saveUser(state.user);
          await secureStorage.saveTokens(
              accessToken: state.user.accessToken,
              refreshToken: state.user.refreshToken);
          await AppPreferences.setLoggedIn(true);

          if (!context.mounted) return;
          Navigator.pushNamedAndRemoveUntil(
              context, '/onboarding-questionnaire', (route) => false);
        } else if (state is ResendVerificationEmailSuccess) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Verification code re-sent to ${state.email}',
              ),
              backgroundColor: const Color(0xFF00C853),
            ),
          );
        } else if (state is SignUpError) {
          // Errors from the signup form are owned by the SignUpScreen below.
          if (state.source == SignUpErrorSource.register) return;

          // A verified existing account was detected (e.g. via resend) —
          // the user can sign in, so send them there instead of the OTP flow.
          if (state.isUserAlreadyExists) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: 'Sign In',
                  textColor: Colors.white,
                  onPressed: () => Navigator.pushReplacementNamed(
                      context, '/signin'),
                ),
              ),
            );
            Future.delayed(const Duration(seconds: 3), () {
              if (!context.mounted) return;
              Navigator.pushReplacementNamed(context, '/signin');
            });
            return;
          }

          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<SignUpBloc, SignUpState>(
          builder: (context, signUpBlocState) {
        if (signUpBlocState is SignUpSuccess) {
          final displayEmail = signUpBlocState.email.isEmpty
              ? (widget.email ?? '')
              : signUpBlocState.email;
          return _buildOtpScreen(context, displayEmail);
        }

        if (signUpBlocState is ResendVerificationEmailSuccess) {
          return _buildOtpScreen(context, signUpBlocState.email);
        }

        if (signUpBlocState is SignUpLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Error or initial — keep OTP screen if email is available
        if (widget.email != null && widget.email!.isNotEmpty) {
          return _buildOtpScreen(context, widget.email!);
        }

        return const Scaffold(
          body: Center(child: Text('Something went wrong')),
        );
      }),
    );
  }
}
