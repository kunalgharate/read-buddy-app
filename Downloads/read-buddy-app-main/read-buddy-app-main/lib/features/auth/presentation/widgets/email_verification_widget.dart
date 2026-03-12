import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/secure_storage_utils.dart';
import '../blocs/sign_up/sign_up_bloc.dart';
import '../pages/sing_up_page.dart';
import 'custom_button_widget.dart';

class EmailVerificationScreen extends StatelessWidget {
  EmailVerificationScreen({super.key});

  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());

  Widget _buildCodeBox(int index, BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2C3E50),
          ),
          decoration: InputDecoration(
            counterText: "",
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFD6D6D6),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
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
    );
  }

  void _verifyOTP(BuildContext context,String email) {
    String otp = _controllers.map((c) => c.text).join();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter complete 6-digit code'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    else
      {
        BlocProvider.of<SignUpBloc>(context).add(VerifyEmailEvent(email,otp));
      }
  }

  void _resendCode(BuildContext context, String email) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Verification code sent to $email'),
        backgroundColor: Colors.blue,
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
      await secureStorage.saveTokens(accessToken: state.user.accessToken, refreshToken:  state.user.refreshToken);

      Navigator.pushNamedAndRemoveUntil(context, '/onboarding-questionnaire', (route) => false);
    }
  },
  child: BlocBuilder<SignUpBloc, SignUpState>(
      builder: (context, signUpBlocState) {
        if(signUpBlocState is SignUpSuccess) {
          return Scaffold(
            backgroundColor: Colors.white,
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
                    signUpBlocState.user.email,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (index) => _buildCodeBox(index, context)),
                  ),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: () => _resendCode(context, signUpBlocState.user.email),
                    child: const Text.rich(
                      TextSpan(
                        text: 'If you did not receive code? ',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                        children: [
                          TextSpan(
                            text: 'Resend',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF0B2545),
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  CustomButton(
                    text: 'Continue',
                    onPressed: () => _verifyOTP(context,signUpBlocState.user.email),
                    backgroundColor: const Color(0xFF00C853),
                  ),
                ],
              ),
            ),
          );
        } else if(signUpBlocState is SignUpLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return const Scaffold(
          body: Center(
            child: Text('Something went wrong'),
          ),
        );
      }
    ),
);
  }
}