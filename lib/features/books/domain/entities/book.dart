import 'package:equatable/equatable.dart';

import '../../data/models/book_model.dart';

class Book extends Equatable {
  final String id;
  final String title;
  final String bookimage;
  final BookCategory book_category;
  final String genre; // ADD

  const Book({
    required this.id,
    required this.title,
    required this.book_category,
    required this.bookimage,
    required this.genre, // ADD
  });

  @override
  List<Object> get props => [id, title, book_category, bookimage, genre];
}