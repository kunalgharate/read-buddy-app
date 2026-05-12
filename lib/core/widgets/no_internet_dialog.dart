import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/connectivity_service.dart';

/// Shows a dialog when internet is unavailable.
/// Has Retry and Cancel buttons. Auto-closes when connectivity is restored.
class NoInternetDialog {
  static bool _isShowing = false;

  /// Show the dialog. Safe to call multiple times — only one will show.
  static void show(BuildContext context) {
    if (_isShowing) return;
    _isShowing = true;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => _NoInternetDialogContent(
        onRetry: () async {
          final connected = await ConnectivityService.instance.checkNow();
          if (connected && ctx.mounted) {
            _dismiss(ctx);
          }
        },
        onCancel: () => _dismiss(ctx),
      ),
    ).then((_) => _isShowing = false);
  }

  /// Dismiss the dialog if it's showing.
  static void dismiss(BuildContext context) {
    if (_isShowing) {
      _dismiss(context);
    }
  }

  static void _dismiss(BuildContext context) {
    if (_isShowing && Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
      _isShowing = false;
    }
  }
}

class _NoInternetDialogContent extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onCancel;

  const _NoInternetDialogContent({
    required this.onRetry,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFD64545).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.wifi_off_rounded,
              size: 36,
              color: Color(0xFFD64545),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Internet Connection',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF052E44),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Some features require internet. '
            'Please check your network settings.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF666666),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          // Retry button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2CE07F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Retry',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Cancel button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: onCancel,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Continue Offline',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF666666),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
