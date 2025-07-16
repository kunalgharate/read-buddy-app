import 'package:flutter/material.dart';

class AboutBookWidget extends StatelessWidget {
  final String about;
<<<<<<< Updated upstream
  const AboutBookWidget({super.key, required this.about});
=======
  const AboutBookWidget({
    super.key,
    required this.about,
  });
>>>>>>> Stashed changes

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 237, 240, 242),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: const Text(
              'About This Book',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
<<<<<<< Updated upstream
                color: Colors.black,
=======
                color: Color.fromRGBO(5, 46, 68, 1),
>>>>>>> Stashed changes
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            about,
            // 'The Design of Everyday Things explains how good design makes everyday objects easy and enjoyable to use. It shows how small changes can make products more useful and how understanding people\'s behavior leads to better design.',
            style: TextStyle(
<<<<<<< Updated upstream
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.6,
              fontWeight: FontWeight.w500,
=======
              fontSize: 14,
              color: Color.fromRGBO(20, 20, 20, 1),
              height: 1.6,
              fontWeight: FontWeight.w400,
              wordSpacing: 0,
              fontFamily: 'popins',
>>>>>>> Stashed changes
            ),
          ),
        ],
      ),
    );
  }
}
