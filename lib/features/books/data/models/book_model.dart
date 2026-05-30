import '../../domain/entities/book.dart';
import '../../domain/entities/book_category.dart';

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
          ? BookCategoryModel.fromJson(categoryJson)
          : const BookCategory(id: '', category_name: ''),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'title': title,
    'coverImageUrl': bookimage,
    'genre': genre,
    'category': BookCategoryModel(id: book_category.id, category_name: book_category.category_name).toJson(),
  };
}

class BookCategoryModel extends BookCategory {
  const BookCategoryModel({
    required super.id,
    required super.category_name,
  });

  factory BookCategoryModel.fromJson(Map<String, dynamic> json) {
    return BookCategoryModel(
      id: (json['_id'] ?? '').toString(),
      category_name: (json['name'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': category_name,
  };
}