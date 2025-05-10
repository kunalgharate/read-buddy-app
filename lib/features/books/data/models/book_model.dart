// features/books/data/models/book_model.dart
import '../../domain/entities/book.dart';

class BookModel extends Book {
  BookModel({
    required String id,
    required String title,
    required String author,
  }) : super(id: id, title: title, author: author);

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['_id'],
      title: json['title'],
      author: json['author'],
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'title': title,
    'author': author,
  };
}
