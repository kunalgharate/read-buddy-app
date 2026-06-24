import 'package:flutter/material.dart';
import 'package:read_buddy_app/core/services/app_preferences.dart';
import 'package:read_buddy_app/core/utils/secure_storage_utils.dart';

/// Shows a non-dismissible dialog when the user's session is replaced by another device.
void showSessionExpiredDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.devices, color: Colors.red),
          SizedBox(width: 8),
          Expanded(child: Text('Session Expired')),
        ],
      ),
      content: const Text(
        'You have been logged out because your account was accessed from another device.\n\n'
        'Only one active session is allowed at a time.',
      ),
      actions: [
        FilledButton(
          onPressed: () async {
            await SecureStorageUtil().clearAll();
            await AppPreferences.clear();
            if (ctx.mounted) {
              Navigator.of(ctx)
                  .pushNamedAndRemoveUntil('/signin', (_) => false);
            }
          },
          child: const Text('Sign In Again'),
        ),
      ],
    ),
  );
}
