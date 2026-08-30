import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../data/datasources/book_report_service.dart';

/// A "Report a concern" text button that opens a bottom sheet to submit a
/// copyright/content report for a book. Self-contained — drop it anywhere a
/// [bookId] is available.
class ReportConcernButton extends StatelessWidget {
  final String bookId;
  const ReportConcernButton({super.key, required this.bookId});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => _openSheet(context),
      style: TextButton.styleFrom(
        foregroundColor: Colors.grey.shade500,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: const Icon(Icons.flag_outlined, size: 15),
      label: const Text('Report a concern', style: TextStyle(fontSize: 12)),
    );
  }

  void _openSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReportSheet(bookId: bookId),
    );
  }
}

class _ReportSheet extends StatefulWidget {
  final String bookId;
  const _ReportSheet({required this.bookId});

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  static const _reasons = <String, String>{
    'copyright': 'Copyright / it should not be here',
    'inappropriate': 'Inappropriate content',
    'incorrect_info': 'Incorrect information',
    'broken_content': 'Broken / unreadable content',
    'other': 'Other',
  };

  String _reason = 'copyright';
  final _details = TextEditingController();
  final _email = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _details.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      await getIt<BookReportService>().report(
        bookId: widget.bookId,
        reason: _reason,
        details: _details.text.trim(),
        contactEmail: _email.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you. Your report has been submitted.'),
          backgroundColor: Color(0xFF2CE07F),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final msg = e is DioException
          ? (e.response?.data?['error']?.toString() ??
              'Could not submit report. Please try again.')
          : 'Could not submit report. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red.shade400),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Report a concern',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(
            'If you believe this book infringes copyright or violates our policies, let us know. Our team is notified immediately.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          const Text('Reason',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: _reason,
            isExpanded: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            ),
            items: _reasons.entries
                .map((e) => DropdownMenuItem(
                    value: e.key,
                    child: Text(e.value,
                        overflow: TextOverflow.ellipsis)))
                .toList(),
            onChanged: (v) => setState(() => _reason = v ?? 'copyright'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _details,
            maxLines: 3,
            maxLength: 2000,
            decoration: const InputDecoration(
              labelText: 'Details (optional)',
              hintText: 'Tell us more…',
              border: OutlineInputBorder(),
            ),
          ),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Your email (optional)',
              hintText: 'For rights holders / follow-up',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(_submitting ? 'Submitting…' : 'Submit report'),
            ),
          ),
        ],
      ),
    );
  }
}
