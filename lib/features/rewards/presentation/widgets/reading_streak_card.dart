import 'package:flutter/material.dart';

class ReadingStreakCard extends StatelessWidget {
  const ReadingStreakCard({super.key});

  @override
  Widget build(BuildContext context) {
    const activeDays = 4; // D1-D4 are active
    const totalDays = 7;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Reading Streak',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Color(0xFF000000),
                ),
              ),
              const Text(
                '7 days',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Color(0xFF052E44),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Day circles
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(totalDays, (index) {
              final isActive = index < activeDays;
              return _DayCircle(
                label: 'D${index + 1}',
                isActive: isActive,
              );
            }),
          ),
          const SizedBox(height: 8),
          const Text(
            '50+ Points for more 5 days',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Color(0xFF000000),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayCircle extends StatelessWidget {
  final String label;
  final bool isActive;

  const _DayCircle({required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF2CE07F)
                : const Color(0xFFEAEAEA),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              Icons.check,
              size: 20,
              color: isActive ? Colors.white : Colors.transparent,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: isActive
                ? const Color(0xFF000000)
                : const Color(0xFF000000).withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }
}
