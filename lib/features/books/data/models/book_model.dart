import '../../domain/entities/book.dart';

class BookModel extends Book {
  const BookModel({
    required super.id,
    required super.title,
    required super.bookimage,
    required super.book_category,
    required super.genre,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    final categoryJson = json['category'];

    return BookModel(
      id: (json['_id'] ?? '').toString(),
      title: (json['title'] ?? 'Unknown Title').toString(),
      bookimage: (json['coverImageUrl'] ?? '').toString(),
      genre: (json['genre'] ?? '').toString(),
      book_category: categoryJson is Map<String, dynamic>
          ? BookCategory.fromJson(categoryJson)
          : BookCategory(id: '', category_name: ''),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'title': title,
    'bookimage': bookimage,
    'genre': genre,
    'book_category': book_category.toJson(),
  };
}  // ← this was missing

class BookCategory {
  final String id;
  final String category_name;

  BookCategory({
    required this.id,
    required this.category_name,
  });

  factory BookCategory.fromJson(Map<String, dynamic> json) {
    return BookCategory(
      id: (json['_id'] ?? '').toString(),
      category_name: (json['name'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': category_name,
  };
}