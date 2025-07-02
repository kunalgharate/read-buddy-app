import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/ui_utils.dart';
import '../blocs/sign_up/sign_up_bloc.dart';
import '../widgets/email_verification_widget.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isPasswordVisible = false;
  String? _phoneError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _validatePhone(String value) {
    setState(() {
      if (value.length > 10) {
        _phoneError = "Phone number cannot exceed 10 digits";
      } else {
        _phoneError = null;
      }
    });
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
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
    if (_formKey.currentState!.validate() && _phoneError == null) {
      final data = {
        "name": _nameController.text.trim(),
        "email": _emailController.text.trim().toLowerCase(),
        "password": _passwordController.text,
        "phno": _phoneController.text.trim().isEmpty ? '' : _phoneController.text.trim(),
        "userRole": "user",
        "picture": "https://example.com/profile.jpg",
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

  void _navigateToSignIn() {
    Navigator.pushReplacementNamed(context, '/signin');
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignUpBloc, SignUpState>(
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
              message: state.message,
              action: SnackBarAction(
                label: 'Sign In',
                textColor: Colors.white,
                onPressed: _navigateToSignIn,
              ),
            );
          } else {
            UiUtils.showErrorSnackBar(
              context,
              message: state.message,
            );
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    const Text(
                      'Create New Account',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E2939),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Name Field
                    const Text(
                      'Name',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _nameController,
                      validator: _validateName,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Enter Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF3182CE)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Email Field
                    const Text(
                      'Email',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _emailController,
                      validator: _validateEmail,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Enter Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF3182CE)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Password Field
                    const Text(
                      'Password',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _passwordController,
                      validator: _validatePassword,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Enter Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            color: const Color(0xFF8895A7),
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF3182CE)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Phone Field (Optional)
                    const Text(
                      'Phone Number (Optional)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      onChanged: _validatePhone,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Enter Phone Number',
                        errorText: _phoneError,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF3182CE)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Sign Up Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: state is SignUpLoading ? null : _handleSignUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3182CE),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: state is SignUpLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Create Account',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Sign In Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account? ',
                          style: TextStyle(color: Color(0xFF8895A7)),
                        ),
                        TextButton(
                          onPressed: _navigateToSignIn,
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              color: Color(0xFF3182CE),
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
    );
  }
}
