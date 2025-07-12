import 'package:flutter/material.dart';

class StatColumn extends StatelessWidget {
  // final IconData icon;
  final String iconPath;
  final String number;
  final String label;

  const StatColumn({
    // required this.icon,
    required this.iconPath,
    required this.number,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Icon(icon, size: 28, color: Colors.blue),
        Image.asset(
          iconPath,
          height: 16,
          width: 16,
        ),
        SizedBox(height: 4),
        Text(number,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color.fromRGBO(5, 46, 68, 1))),
        SizedBox(height: 2),
        Text(label,
            style: TextStyle(
              fontSize: 16,
              wordSpacing: 0,
              fontWeight: FontWeight.w500,
              color: Color.fromRGBO(20, 20, 20, 1),
            )),
      ],
    );
  }
}
