import 'package:equatable/equatable.dart';

import 'book_category.dart';

class Book extends Equatable {
  final String id;
  final String title;
  final String bookimage;
  final BookCategory bookCategory;
  final String genre; // ADD

  const Book({
    required this.id,
    required this.title,
    required this.bookCategory,
    required this.bookimage,
    required this.genre, // ADD
  });

  @override
  List<Object> get props => [id, title, bookCategory, bookimage, genre];
}
