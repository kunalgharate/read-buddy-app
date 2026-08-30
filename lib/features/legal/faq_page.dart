import 'package:flutter/material.dart';
import 'widgets/legal_page.dart';

/// Help / FAQ page — reuses the LegalPage scaffold. Content reflects
/// ReadBuddy's actual rules (borrow budget, page-based due dates, Prime,
/// resume/continue-reading, reporting).
class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalPage(
      title: 'Help & FAQ',
      lastUpdated: 'Everything you need to know about using ReadBuddy',
      contactIntro: 'Still need help? Contact us at:',
      contactEmail: 'readbuddyin@gmail.com',
      sections: [
        LegalSection(
          heading: 'How do I find and borrow a book?',
          body:
              'Browse or search the library, open a book, and add it to your borrow order. Physical books are copies donated by the community — you borrow and return them, just like a local library.',
        ),
        LegalSection(
          heading: 'How many books can I borrow at once?',
          body:
              'Borrowing is limited by a per-order budget (currently ₹500 worth of books per order), so the number depends on the books you choose. A small delivery/pickup fee (currently ₹25) may apply.',
        ),
        LegalSection(
          heading: 'How long can I keep a book?',
          body:
              'Due dates depend on the book\'s length — roughly 30 days for shorter books and up to 90 days for longer ones. Your exact due date is shown when your order is approved. You can request an extension (usually 30 more days), subject to a limit.',
        ),
        LegalSection(
          heading: 'What digital formats are available?',
          body:
              'eBooks (PDF/EPUB), audiobooks, and video books — readable, listenable, or watchable right inside the app.',
        ),
        LegalSection(
          heading: 'Does it remember where I left off?',
          body:
              'Yes. Your reading, listening, and watching position is saved automatically and syncs across your devices, so you can continue exactly where you stopped — shown under "Continue Reading" on the home screen.',
        ),
        LegalSection(
          heading: 'Where does the digital content come from?',
          body:
              'We only offer digital books that are public domain, openly licensed, or authorised by the rights holder. We do not host unauthorised copies.',
        ),
        LegalSection(
          heading: 'What does Prime membership give me?',
          body:
              'Prime unlocks the full library across all formats. You can get Prime by subscribing or by donating books to the community — each approved donation adds membership time (currently 30 days per book).',
        ),
        LegalSection(
          heading: 'Can I donate or contribute a book?',
          body:
              'Yes. Donate a physical book and it joins the shared library. You may contribute a digital book only if you have the right to share it (public domain, openly licensed, or you are the rights holder).',
        ),
        LegalSection(
          heading: 'A book shouldn\'t be here — how do I report it?',
          body:
              'Every book has a "Report a concern" option. Our team is alerted immediately and will review it. See our Copyright & Takedown Policy for details.',
        ),
      ],
    );
  }
}
