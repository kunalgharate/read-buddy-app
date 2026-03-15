import 'package:flutter/material.dart';

class _OptionTile extends StatelessWidget {
  final String option;
  final bool isSelected;
  final bool isMulti;
  final VoidCallback onTap;

  const _OptionTile({
    required this.option,
    required this.isSelected,
    required this.isMulti,
    required this.onTap,
  });

  static const Color primaryGreen = Color(0xFF3DDC84);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? primaryGreen.withOpacity(0.12) : Colors.white,
          border: Border.all(
            color: isSelected ? primaryGreen : Colors.grey.shade300,
            width: isSelected ? 1.8 : 1.2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22,
              height: 22,
              decoration: isMulti
                  ? BoxDecoration(
                color: isSelected ? primaryGreen : Colors.transparent,
                border: Border.all(
                  color: isSelected ? primaryGreen : Colors.grey.shade400,
                  width: 1.8,
                ),
                borderRadius: BorderRadius.circular(5),
              )
                  : BoxDecoration(
                color: isSelected ? primaryGreen : Colors.transparent,
                border: Border.all(
                  color: isSelected ? primaryGreen : Colors.grey.shade400,
                  width: 1.8,
                ),
                shape: BoxShape.circle,
              ),
              child: isSelected
                  ? Icon(
                isMulti ? Icons.check : Icons.circle,
                size: isMulti ? 14 : 10,
                color: Colors.white,
              )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? Colors.black87 : Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}