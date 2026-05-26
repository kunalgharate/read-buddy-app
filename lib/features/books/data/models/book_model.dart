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
          ? BookCategoryModel.fromJson(categoryJson)
          : const BookCategory(id: '', category_name: ''),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'title': title,
    'coverImageUrl': bookimage,
    'genre': genre,
    'category': book_category is BookCategoryModel 
        ? (book_category as BookCategoryModel).toJson() 
        : BookCategoryModel.fromEntity(book_category).toJson(),
  };
}  // ← this was missing

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

  factory BookCategoryModel.fromEntity(BookCategory entity) {
    return BookCategoryModel(
      id: entity.id,
      category_name: entity.category_name,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': category_name,
  };
}