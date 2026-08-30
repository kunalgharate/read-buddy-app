import 'package:flutter/material.dart';
import 'widgets/legal_page.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalPage(
      title: 'Terms of Service',
      lastUpdated: 'Last updated: August 2026',
      contactIntro:
          'If you have any questions or concerns regarding these Terms of Service, please contact us at:',
      contactEmail: 'support@readbuddy.in',
      sections: [
        LegalSection(
          heading: '1. Acceptance of Terms',
          body:
              'By accessing or using the ReadBuddy application, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the app. We reserve the right to update or modify these terms at any time, and your continued use of the app constitutes acceptance of any changes.',
        ),
        LegalSection(
          heading: '2. User Account',
          body:
              '• You must register an account to access ReadBuddy\'s services.\n'
              '• You are responsible for maintaining the security and confidentiality of your account credentials.\n'
              '• All information provided during registration must be truthful, accurate, and up to date.\n'
              '• You must not share your account with others or create multiple accounts.\n'
              '• ReadBuddy reserves the right to suspend or terminate accounts that violate these terms.',
        ),
        LegalSection(
          heading: '3. Prime Membership',
          body: '• Prime Membership requires a minimum donation of ₹100.\n'
              '• The membership is valid for 1 year from the date of activation.\n'
              '• Benefits include priority book access, free delivery on select orders, and exclusive member-only collections.\n'
              '• Membership is non-transferable and tied to your registered account.\n'
              '• ReadBuddy reserves the right to modify membership benefits with prior notice.',
        ),
        LegalSection(
          heading: '4. Book Borrowing',
          body:
              '• You are responsible for the care and safety of borrowed books.\n'
              '• Books must be returned within the specified return timeline as mentioned at the time of borrowing.\n'
              '• Books must be returned in the same condition as received. Any damage or loss may result in penalties.\n'
              '• Failure to return books on time may lead to restrictions on your account.\n'
              '• ReadBuddy is not liable for any content within the borrowed books.',
        ),
        LegalSection(
          heading: '5. Donation Policy',
          body:
              '• ReadBuddy accepts donations in the form of books and monetary contributions.\n'
              '• All donated books undergo a verification process to ensure quality and appropriateness.\n'
              '• Monetary donations are used to support the platform\'s operations, book procurement, and community initiatives.\n'
              '• Donations are voluntary and non-refundable once processed.\n'
              '• ReadBuddy reserves the right to reject book donations that do not meet quality standards.',
        ),
        LegalSection(
          heading: '6. Intellectual Property',
          body:
              'All content, trademarks, logos, and intellectual property displayed on the ReadBuddy app are owned by or licensed to ReadBuddy. You may not reproduce, distribute, or create derivative works from any content on the platform without prior written permission. The books available on the platform are the intellectual property of their respective authors and publishers.',
        ),
        LegalSection(
          heading: '7. Limitation of Liability',
          body:
              'ReadBuddy is provided on an "as is" and "as available" basis. We do not guarantee uninterrupted or error-free service. ReadBuddy shall not be liable for any indirect, incidental, special, or consequential damages arising from the use or inability to use the app. Our total liability shall not exceed the amount paid by you for the Prime Membership in the preceding 12 months.',
        ),
        LegalSection(
          heading: '8. Termination',
          body:
              '• ReadBuddy reserves the right to block or terminate your account at any time for violation of these terms.\n'
              '• Grounds for termination include misuse of the platform, fraudulent activity, abuse of borrowed books, or harassment of other users.\n'
              '• Upon termination, you must return all borrowed books immediately.\n'
              '• Any remaining membership benefits will be forfeited upon account termination.',
        ),
      ],
    );
  }
}
