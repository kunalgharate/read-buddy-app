// lib/features/books/presentation/widgets/book_list_item.dart
import 'package:flutter/material.dart';
import '../../domain/entities/book.dart';

class BookListItem extends StatelessWidget {
  final Book book;

  const BookListItem({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.book),
      title: Text(book.title),
      subtitle: Text(book.author),
    );
  }
}
