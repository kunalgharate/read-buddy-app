import 'package:flutter/material.dart';

class UiUtils {
  static void showSnackBar(
    BuildContext context, {
    required String message,
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        backgroundColor: isError 
            ? const Color(0xFFE53E3E) 
            : const Color(0xFF38A169),
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        action: action,
      ),
    );
  }

  static void showErrorSnackBar(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    showSnackBar(
      context,
      message: message,
      isError: true,
      duration: duration,
      action: action,
    );
  }

  static void showSuccessSnackBar(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    showSnackBar(
      context,
      message: message,
      isError: false,
      duration: duration,
    );
  }

  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(message),
            ],
          ],
        ),
      ),
    );
  }

  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  static void showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: onCancel ?? () => Navigator.of(context).pop(),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}
