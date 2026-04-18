import 'package:flutter/material.dart';

class ChallengesSection extends StatelessWidget {
  const ChallengesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Current Challenges',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Color(0xFF052E44),
          ),
        ),
        const SizedBox(height: 10),
        const _ChallengeCard(
          title: 'Read 2 Book in this Week',
          progress: '1/3',
          points: 100,
          backgroundColor: Color(0xFFEAEAEA),
        ),
        const SizedBox(height: 8),
        const _ChallengeCard(
          title: 'Write your Review',
          progress: '0/3',
          points: 100,
          backgroundColor: Color(0xFFE0E0E0),
        ),
      ],
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  final String title;
  final String progress;
  final int points;
  final Color backgroundColor;

  const _ChallengeCard({
    required this.title,
    required this.progress,
    required this.points,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          // Green circle with checkmark icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF2CE07F),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.menu_book,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          // Title and progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Color(0xFF000000),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  progress,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Color(0xFF000000),
                  ),
                ),
              ],
            ),
          ),
          // Points
          Row(
            children: [
              const Icon(Icons.star_outline,
                  color: Color(0xFFFFB800), size: 24),
              const SizedBox(width: 6),
              Text(
                '$points',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Color(0xFF2CE07F),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
