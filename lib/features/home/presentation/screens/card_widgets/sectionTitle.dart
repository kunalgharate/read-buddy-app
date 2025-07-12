import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color.fromRGBO(5, 46, 68, 1),
                fontFamily: 'popins'),
          ),
          //Icon have to added how a image icon

          Image.asset(
            'assets/icons/tabler_arrow-right.png',
            height: 24,
            width: 24,
          ),
        ],
      ),
    );
  }
}
