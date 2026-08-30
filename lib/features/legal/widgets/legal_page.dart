import 'package:flutter/material.dart';

/// A single section within a legal document.
class LegalSection {
  final String heading;
  final String body;
  const LegalSection({required this.heading, required this.body});
}

/// Shared scaffold for legal / policy pages (Terms, Privacy, Refund).
///
/// Centralizes the layout, heading/body styling, "last updated" line, and the
/// selectable contact email so each policy page only supplies its content.
class LegalPage extends StatelessWidget {
  final String title;
  final String lastUpdated;
  final List<LegalSection> sections;

  /// Optional contact email rendered as selectable text at the bottom.
  final String? contactEmail;

  /// Optional intro line shown above the contact email.
  final String contactIntro;

  const LegalPage({
    super.key,
    required this.title,
    required this.lastUpdated,
    required this.sections,
    this.contactEmail,
    this.contactIntro =
        'If you have any questions or concerns, please contact us at:',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headingStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: theme.colorScheme.onSurface,
      height: 1.5,
    );
    final bodyStyle = TextStyle(
      fontSize: 14,
      color: theme.colorScheme.onSurface,
      height: 1.6,
    );

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              lastUpdated,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            for (final section in sections) ...[
              Text(section.heading, style: headingStyle),
              const SizedBox(height: 8),
              Text(section.body, style: bodyStyle),
              const SizedBox(height: 20),
            ],
            if (contactEmail != null) ...[
              Text(contactIntro, style: bodyStyle),
              const SizedBox(height: 4),
              SelectableText(
                contactEmail!,
                style: bodyStyle.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
