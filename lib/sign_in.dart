import 'package:flutter/material.dart';
import 'forget_password.dart';
import 'sing_up.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? width;
  final double? height;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Widget? icon;
  final bool isOutlined;
  final double borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.width,
    this.height = 56.0,
    this.fontSize = 18.0,
    this.fontWeight = FontWeight.w500,
    this.icon,
    this.isOutlined = false,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: isOutlined
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: borderColor ?? const Color(0xFFD0D5DD)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                backgroundColor: backgroundColor ?? Colors.white.withOpacity(0.8),
              ),
              child: _buildButtonContent(),
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor ?? const Color(0xFF24D67F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
              child: _buildButtonContent(),
            ),
    );
  }

  Widget _buildButtonContent() {
    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon!,
          const SizedBox(width: 12.0),
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: textColor ?? (isOutlined ? const Color(0xFF1E2939) : Colors.white),
            ),
          ),
        ],
      );
    } else {
      return Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: textColor ?? (isOutlined ? const Color(0xFF1E2939) : Colors.white),
        ),
      );
    }
  }
}

class CustomTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;

  const CustomTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.textColor,
    this.fontSize = 16.0,
    this.fontWeight = FontWeight.w500,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: textColor ?? const Color(0xFF5B6675),
        ),
      ),
    );
  }
}

class ReadBuddyLoginScreen extends StatefulWidget {
  const ReadBuddyLoginScreen({super.key});

  @override
  State<ReadBuddyLoginScreen> createState() => _ReadBuddyLoginScreenState();
}

class _ReadBuddyLoginScreenState extends State<ReadBuddyLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _emailError;
  String? _passwordError;
  bool _obscurePassword = true;

  void _validateAndLogin() {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    // Validate email
    if (email.isEmpty) {
      setState(() {
        _emailError = "Please enter your email";
      });
      return;
    } else if (!_isValidEmail(email)) {
      setState(() {
        _emailError = "Please enter a valid email address";
      });
      return;
    }

    // Validate password
    if (password.isEmpty) {
      setState(() {
        _passwordError = "Please enter your password";
      });
      return;
    }

    // Handle successful validation - you can add your logic here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Login form validated successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'Enter Email ID',
                          hintStyle: const TextStyle(
                            color: Color(0xFF8895A7),
                            fontSize: 18.0,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                          prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF5B6675)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                              color: _emailError != null ? Colors.red : const Color(0xFFD0D5DD),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                              color: _emailError != null ? Colors.red : const Color(0xFFD0D5DD),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                              color: _emailError != null ? Colors.red : const Color(0xFF24D67F),
                              width: 2.0,
                            ),
                          ),
                        ),
                      ),
                      if (_emailError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0, left: 12.0),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red, size: 16.0),
                              const SizedBox(width: 4.0),
                              Text(
                                _emailError!,
                                style: const TextStyle(color: Colors.red, fontSize: 14.0),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 20.0),

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
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: 'Enter Password',
                          hintStyle: const TextStyle(
                            color: Color(0xFF8895A7),
                            fontSize: 18.0,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF5B6675)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                              color: _passwordError != null ? Colors.red : const Color(0xFFD0D5DD),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                              color: _passwordError != null ? Colors.red : const Color(0xFFD0D5DD),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                              color: _passwordError != null ? Colors.red : const Color(0xFF24D67F),
                              width: 2.0,
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: const Color(0xFF5B6675),
                            ),
                            onPressed: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                          ),
                        ),
                      ),
                      if (_passwordError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0, left: 12.0),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red, size: 16.0),
                              const SizedBox(width: 4.0),
                              Expanded(
                                child: Text(
                                  _passwordError!,
                                  style: const TextStyle(color: Colors.red, fontSize: 14.0),
                                ),
                              ),
                            ],
                          ),
                        ),

                      Align(
                        alignment: Alignment.centerRight,
                        child: CustomTextButton(
                          text: 'Forgot Password?',
                          onPressed: () {
                            String email = _emailController.text.trim();
                            if (email.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter your email first'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ForgotPasswordScreen(email: email),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 16.0),

                      CustomButton(
                        text: 'Sign In',
                        width: double.infinity,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600,
                        backgroundColor: const Color(0xFF24D67F),
                        textColor: Colors.white,
                        onPressed: _validateAndLogin,
                      ),

                      const SizedBox(height: 16.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account? ", style: TextStyle(fontSize: 16.0)),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const CreateAccountScreen()),
                              );
                            },
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E2939),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24.0),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Or Continue with', style: TextStyle(fontSize: 16.0, color: Color(0xFF5B6675))),
                        ],
                      ),
                      const SizedBox(height: 24.0),

                      CustomButton(
                        text: 'Sign In with Google',
                        width: double.infinity,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w500,
                        backgroundColor: Colors.white.withOpacity(0.8),
                        textColor: const Color(0xFF1E2939),
                        borderColor: const Color(0xFFD0D5DD),
                        isOutlined: true,
                        icon: Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black),
                          alignment: Alignment.center,
                          child: const Text(
                            'G',
                            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w900, color: Colors.white),
                          ),
                        ),
                        onPressed: () {
                          // Google sign-in logic can be added here
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Google Sign In pressed'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                      const Spacer(flex: 1),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}