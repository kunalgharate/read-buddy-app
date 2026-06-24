import 'package:flutter/material.dart';
import 'package:read_buddy_app/features/bookcrud/presentation/pages/Add/add_book_page.dart';

/// BookStepper is now a simple wrapper around the simplified AddBookPage.
/// The old 2-step flow is no longer needed since the new API only requires
/// title, author, publisher, description, categories, tags, coverImage.
class BookStepper extends StatelessWidget {
  const BookStepper({super.key});

  @override
  Widget build(BuildContext context) {
    return const AddBookPage();
  }
}
