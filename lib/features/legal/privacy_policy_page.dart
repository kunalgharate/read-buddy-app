import 'package:flutter/material.dart';
import 'widgets/legal_page.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalPage(
      title: 'Privacy Policy',
      lastUpdated: 'Last updated: August 2026',
      contactIntro:
          'If you have any questions or concerns regarding this Privacy Policy or your personal data, please contact us at:',
      contactEmail: 'privacy@readbuddy.in',
      sections: [
        LegalSection(
          heading: 'Overview',
          body:
              'At ReadBuddy, we are committed to protecting your privacy. This Privacy Policy explains how we collect, use, store, and protect your personal information when you use our application.',
        ),
        LegalSection(
          heading: '1. Information We Collect',
          body:
              'We collect the following information to provide and improve our services:\n\n'
              '• Name — to personalize your account and communications.\n'
              '• Email address — for account verification, notifications, and support.\n'
              '• Phone number — for delivery coordination and account recovery.\n'
              '• Address — for book delivery and pickup services.\n'
              '• Device information — including device model, operating system, and app version for troubleshooting and optimization.',
        ),
        LegalSection(
          heading: '2. How We Use Information',
          body: 'Your information is used for the following purposes:\n\n'
              '• Account management — creating and maintaining your ReadBuddy account.\n'
              '• Book delivery — processing and coordinating book deliveries and returns.\n'
              '• Notifications — sending order updates, membership reminders, and important announcements.\n'
              '• Service improvement — analyzing usage patterns to enhance user experience.\n'
              '• Customer support — resolving queries and providing assistance.',
        ),
        LegalSection(
          heading: '3. Data Storage',
          body:
              '• Your data is stored in MongoDB databases hosted on secure servers.\n'
              '• We use industry-standard encryption and security measures to protect your data.\n'
              '• Access to the database is restricted to authorized personnel only.\n'
              '• Regular backups are performed to prevent data loss.',
        ),
        LegalSection(
          heading: '4. Third-Party Services',
          body:
              'We use the following third-party services to enhance our platform:\n\n'
              '• Razorpay — for secure payment processing of donations and memberships. Razorpay may collect payment-related information as per their privacy policy.\n'
              '• Google Auth — for secure and convenient sign-in. Google may collect authentication-related data as per their privacy policy.\n'
              '• Firebase — for push notifications, analytics, and crash reporting. Firebase may collect device and usage data as per Google\'s privacy policy.\n\n'
              'We encourage you to review the privacy policies of these third-party services.',
        ),
        LegalSection(
          heading: '5. Data Retention',
          body:
              '• We retain your personal data for as long as your account is active or as needed to provide services.\n'
              '• If you delete your account, your personal data will be removed within 30 days, except where retention is required by law.\n'
              '• Transaction records may be retained for up to 5 years for legal and accounting purposes.\n'
              '• Anonymized data may be retained indefinitely for analytics.',
        ),
        LegalSection(
          heading: '6. User Rights',
          body:
              'You have the following rights regarding your personal data:\n\n'
              '• Access — you can request a copy of the personal data we hold about you.\n'
              '• Update — you can update your personal information at any time through the app settings.\n'
              '• Delete — you can request deletion of your account and associated personal data by contacting us.\n\n'
              'To exercise any of these rights, please contact us using the details below.',
        ),
      ],
    );
  }
}
