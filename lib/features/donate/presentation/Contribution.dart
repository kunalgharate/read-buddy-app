import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ContributionsScreen extends StatelessWidget {
  const ContributionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Reduced top spacer to shift content upwards
            const Spacer(flex: 1), // Was flex: 2

            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SvgPicture.asset(
                  'assets/amico.svg', // Ensure this SVG is your gift box icon
                  height: 180,
                  width: 180,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Reduced spacing between image and "Thank you!"
            const SizedBox(height: 25), // Was 40

            const Text(
              'Thank you!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
                letterSpacing: 0.5,
              ),
            ),

            // Reduced spacing between "Thank you!" and description
            const SizedBox(height: 15), // Was 20

            const Text(
              "We'll call you soon to collect your\ndonated book.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                height: 1.5,
                color: Colors.black87,
                fontWeight: FontWeight.w400,
              ),
            ),

            // Reduced spacing between description and button
            const SizedBox(height: 30), // Was 40

            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00C853).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C853),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.home_outlined,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Go back to home',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(), // Keeps original flex: 1 at the bottom
          ],
        ),
      ),
    );
  }
}