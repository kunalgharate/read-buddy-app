import 'package:flutter/material.dart';
import 'widgets/legal_page.dart';

class CopyrightPolicyPage extends StatelessWidget {
  const CopyrightPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalPage(
      title: 'Copyright & Takedown Policy',
      lastUpdated: 'Last updated: August 2026',
      contactIntro:
          'To report copyright infringement or any other concern, use the "Report a concern" option on any book, or email us at:',
      contactEmail: 'readbuddyin@gmail.com',
      sections: [
        LegalSection(
          heading: '1. Our Commitment',
          body:
              'ReadBuddy respects intellectual property rights. Physical books are donated copies we lend from one reader to another. Digital content (eBooks, audiobooks, video books) is offered only where it is in the public domain, openly licensed, or authorised by the rights holder. We do not host unauthorised copies.',
        ),
        LegalSection(
          heading: '2. Reporting a Concern',
          body:
              'If you are a copyright owner (or their agent) and believe content infringes your rights, or you notice any other issue with a book, use the "Report a concern" option shown on every book. Please include the book title, the work you believe is infringed, your contact details, and a statement that the use is not authorised.',
        ),
        LegalSection(
          heading: '3. How We Respond',
          body:
              'Every report immediately alerts our team. We review reports promptly and, where a concern is valid, we hide or remove the content. In line with India\'s Information Technology Act, 2000 and the Intermediary Guidelines, we act on valid legal notices and court/government orders within the timelines required by law.',
        ),
        LegalSection(
          heading: '4. Repeat Infringers',
          body:
              'Accounts that repeatedly contribute infringing content may be suspended or terminated.',
        ),
        LegalSection(
          heading: '5. Grievance Officer',
          body:
              'In accordance with Indian law, our Grievance Officer can be reached at readbuddyin@gmail.com, [ENTITY ADDRESS], Nashik, Maharashtra, India. (Details to be finalised with the registered entity before launch.)',
        ),
      ],
    );
  }
}
