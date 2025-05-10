// features/books/domain/entities/book.dart
import 'package:equatable/equatable.dart';

class Book extends Equatable {
  final String id;
  final String title;
  final String author;

  const Book({
    required this.id,
    required this.title,
    required this.author,
  });

  @override
  List<Object> get props => [id, title, author];
}
