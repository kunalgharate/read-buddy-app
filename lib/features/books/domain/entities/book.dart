import 'package:equatable/equatable.dart';

class BookCategory extends Equatable {
  final String id;
  final String category_name;

  const BookCategory({
    required this.id,
    required this.category_name,
  });

  @override
  List<Object> get props => [id, category_name];
}

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