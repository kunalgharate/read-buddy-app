import 'package:flutter/material.dart';

class DashboardBoxWidget extends StatelessWidget {
  final String title;
  final int count;
  final IconData? icon;
  final Color? color;

  final void Function() onPressed;
  const DashboardBoxWidget({
    super.key,
    required this.title,
    required this.count,
    required this.onPressed,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final boxColor = color ?? Colors.white;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: boxColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (icon != null)
              Icon(icon, size: 32, color: Colors.teal),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(count.toString(), style: const TextStyle(fontSize: 20)),
            ElevatedButton(
              onPressed: onPressed,
              // onPressed: () {
              //   // TODO: navigate or show details
              // },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("View All"),
            ),
          ],
        ),
      ),
    );
  }
}
