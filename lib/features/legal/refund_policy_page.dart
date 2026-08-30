import 'package:flutter/material.dart';
import 'widgets/legal_page.dart';

class RefundPolicyPage extends StatelessWidget {
  const RefundPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalPage(
      title: 'Refund Policy',
      lastUpdated: 'Last updated: August 2026',
      contactIntro:
          'For any refund-related queries or to initiate a refund request for eligible items, please contact us at:',
      contactEmail: 'support@readbuddy.in',
      sections: [
        LegalSection(
          heading: 'Overview',
          body:
              'At ReadBuddy, we strive to provide the best experience for our community. Please review our refund policy below to understand the terms regarding donations, memberships, and services.',
        ),
        LegalSection(
          heading: '1. Donations Are Non-Refundable',
          body:
              '• All donations made to ReadBuddy, whether in the form of books or monetary contributions, are non-refundable.\n'
              '• Book donations, once accepted and verified, become part of the ReadBuddy community library and cannot be returned.\n'
              '• Monetary donations are used to support platform operations and community initiatives and cannot be reversed once processed.',
        ),
        LegalSection(
          heading: '2. Prime Membership',
          body: '• Prime Membership fees are non-refundable after activation.\n'
              '• Once your membership is activated, you will have access to all Prime benefits for the full duration of 1 year.\n'
              '• No partial or prorated refunds will be provided for early cancellation or account termination.\n'
              '• If you experience issues with your membership activation, please contact support within 24 hours.',
        ),
        LegalSection(
          heading: '3. Delivery Fee',
          body: '• The standard delivery fee is ₹25 per order.\n'
              '• If a book is not delivered within 7 days of the confirmed delivery date, the delivery fee of ₹25 is fully refundable.\n'
              '• To claim a delivery fee refund, please contact support with your order details.\n'
              '• Refunds will be processed within 5–7 business days to your original payment method.',
        ),
        LegalSection(
          heading: '4. Damaged Books',
          body:
              '• If you receive a damaged book, ReadBuddy will provide a replacement, not a refund.\n'
              '• You must report the damage within 48 hours of receiving the book, along with photographic evidence.\n'
              '• The damaged book must be returned to ReadBuddy before a replacement is dispatched.\n'
              '• If a replacement is not available, ReadBuddy will offer an alternative book of similar genre and value.',
        ),
      ],
    );
  }
}
