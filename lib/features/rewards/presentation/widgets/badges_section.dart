import 'package:flutter/material.dart';

class BadgesSection extends StatelessWidget {
  const BadgesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Badges',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Color(0xFF052E44),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            _BadgeItem(
              label: 'Book\nBeginner',
              isUnlocked: true,
            ),
            _BadgeItem(
              label: 'Page\nTurner',
              isUnlocked: true,
            ),
            _BadgeItem(
              label: 'Book\nNerd',
              isUnlocked: false,
            ),
            _BadgeItem(
              label: 'Library\n Hero',
              isUnlocked: false,
            ),
          ],
        ),
      ],
    );
  }
}

class _BadgeItem extends StatelessWidget {
  final String label;
  final bool isUnlocked;

  const _BadgeItem({required this.label, required this.isUnlocked});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color:
                isUnlocked ? const Color(0xFF2CE07F) : const Color(0xFFEAEAEA),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            Icons.menu_book_outlined,
            size: 22,
            color: isUnlocked ? Colors.white : Colors.grey.shade400,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: isUnlocked
                ? const Color(0xFF000000)
                : const Color(0xFF000000).withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }
}
