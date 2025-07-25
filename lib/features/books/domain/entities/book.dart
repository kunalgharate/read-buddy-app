// features/books/domain/entities/book.dart
import 'package:equatable/equatable.dart';
import 'package:read_buddy_app/features/books/data/models/book_model.dart';

class Book extends Equatable {
  final String id;
  final String title;
  final String bookimage;
  final BookCategory bookCategory;

  final String bookId; //final List<String> authors;

  const Book({
    required this.id,
    required this.title,
    required this.bookCategory,
    required this.bookimage,
    required this.bookId,

    // required this.authors,
  });

  @override
  List<Object> get props => [id, title, bookCategory, bookimage, bookId];
}
