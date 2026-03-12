// features/books/domain/entities/book.dart
import 'package:equatable/equatable.dart';
import 'package:read_buddy_app/features/books/data/models/book_model.dart';

class Book extends Equatable {
  final String id;
  final String title;
  final String bookimage;
  final BookCategory book_category;
  //final List<String> authors;

  const Book(
      {required this.id,
      required this.title,
      required this.book_category,
      required this.bookimage
      // required this.authors,
      });

  @override
  List<Object> get props => [id, title, book_category, bookimage];
}
