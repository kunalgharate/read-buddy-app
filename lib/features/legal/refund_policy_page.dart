import 'package:flutter/material.dart';

class RefundPolicyPage extends StatelessWidget {
  const RefundPolicyPage({super.key});

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
      appBar: AppBar(
        title: const Text('Refund Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Refund Policy',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Last updated: August 2026',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'At ReadBuddy, we strive to provide the best experience for our community. Please review our refund policy below to understand the terms regarding donations, memberships, and services.',
              style: bodyStyle,
            ),
            const SizedBox(height: 24),

            // 1. Donations Are Non-Refundable
            Text('1. Donations Are Non-Refundable', style: headingStyle),
            const SizedBox(height: 8),
            Text(
              '• All donations made to ReadBuddy, whether in the form of books or monetary contributions, are non-refundable.\n'
              '• Book donations, once accepted and verified, become part of the ReadBuddy community library and cannot be returned.\n'
              '• Monetary donations are used to support platform operations and community initiatives and cannot be reversed once processed.',
              style: bodyStyle,
            ),
            const SizedBox(height: 20),

            // 2. Prime Membership
            Text('2. Prime Membership', style: headingStyle),
            const SizedBox(height: 8),
            Text(
              '• Prime Membership fees are non-refundable after activation.\n'
              '• Once your membership is activated, you will have access to all Prime benefits for the full duration of 1 year.\n'
              '• No partial or prorated refunds will be provided for early cancellation or account termination.\n'
              '• If you experience issues with your membership activation, please contact support within 24 hours.',
              style: bodyStyle,
            ),
            const SizedBox(height: 20),

            // 3. Delivery Fee
            Text('3. Delivery Fee', style: headingStyle),
            const SizedBox(height: 8),
            Text(
              '• The standard delivery fee is ₹25 per order.\n'
              '• If a book is not delivered within 7 days of the confirmed delivery date, the delivery fee of ₹25 is fully refundable.\n'
              '• To claim a delivery fee refund, please contact support with your order details.\n'
              '• Refunds will be processed within 5–7 business days to your original payment method.',
              style: bodyStyle,
            ),
            const SizedBox(height: 20),

            // 4. Damaged Books
            Text('4. Damaged Books', style: headingStyle),
            const SizedBox(height: 8),
            Text(
              '• If you receive a damaged book, ReadBuddy will provide a replacement, not a refund.\n'
              '• You must report the damage within 48 hours of receiving the book, along with photographic evidence.\n'
              '• The damaged book must be returned to ReadBuddy before a replacement is dispatched.\n'
              '• If a replacement is not available, ReadBuddy will offer an alternative book of similar genre and value.',
              style: bodyStyle,
            ),
            const SizedBox(height: 20),

            // 5. Contact
            Text('5. Contact', style: headingStyle),
            const SizedBox(height: 8),
            Text(
              'For any refund-related queries or to initiate a refund request for eligible items, please contact us at:',
              style: bodyStyle,
            ),
            const SizedBox(height: 4),
            Text(
              'support@readbuddy.in',
              style: bodyStyle.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
