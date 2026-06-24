import 'package:flutter/material.dart';

/// Shows a dialog informing non-prime users they need to donate to access content.
/// Returns true if user tapped "Donate Now", false otherwise.
Future<bool> showPrimeRequiredDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.lock_outline, color: Theme.of(ctx).colorScheme.primary),
          const SizedBox(width: 8),
          const Expanded(child: Text('Prime Membership Required')),
        ],
      ),
      content: const Text(
        'To access books, audiobooks, and other content, you need to become a Prime member.\n\n'
        'Donate a book or ₹100+ to unlock full access to the ReadBuddy library.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Later'),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.pop(ctx, true),
          icon: const Icon(Icons.volunteer_activism, size: 18),
          label: const Text('Donate Now'),
        ),
      ],
    ),
  );

  if (result == true && context.mounted) {
    Navigator.pushNamed(context, '/donation');
  }
  return result ?? false;
}
