// features/books/data/models/book_model.dart
import '../../domain/entities/book.dart';

class BookModel extends Book {
  BookModel({
    required String id,
    required String title,
   // required List<String> authors,
  }) : super(id: id, title: title);

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['_id'],
      title: json['title'] ?? 'Unknown Title',
    //  authors: json['authors'],
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'title': title,
   // 'authors': authors,
  };
}
