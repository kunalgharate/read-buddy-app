import '../../domain/entities/book.dart';
import '../../domain/entities/book_category.dart';

class BookModel extends Book {
  const BookModel({
    required super.id,
    required super.title,
    required super.bookimage,
    required super.bookCategory,
    required super.genre,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    // Handle multiple category formats from the API:
    // 1. "categories": [{ _id, name }] — new populated array
    // 2. "category": { _id, name } — old populated object
    // 3. "category": "687671ae..." — old string ID
    // 4. "category": ["id1", "id2"] — old array of string IDs
    String categoryId = '';
    String categoryName = '';

    final categoriesData = json['categories'];
    final categoryData = json['category'];

    if (categoriesData is List && categoriesData.isNotEmpty) {
      final first = categoriesData.first;
      if (first is Map<String, dynamic>) {
        categoryId = (first['_id'] ?? '').toString();
        categoryName = (first['name'] ?? '').toString();
      } else if (first is String) {
        categoryId = first;
      }
    } else if (categoryData is Map<String, dynamic>) {
      categoryId = (categoryData['_id'] ?? '').toString();
      categoryName = (categoryData['name'] ?? '').toString();
    } else if (categoryData is List && categoryData.isNotEmpty) {
      final first = categoryData.first;
      if (first is Map<String, dynamic>) {
        categoryId = (first['_id'] ?? '').toString();
        categoryName = (first['name'] ?? '').toString();
      } else if (first is String) {
        categoryId = first;
      }
    } else if (categoryData is String && categoryData.isNotEmpty) {
      categoryId = categoryData;
    }

    return BookModel(
      id: (json['_id'] ?? '').toString(),
      title: (json['title'] ?? 'Unknown Title').toString(),
      bookimage: (json['coverImageUrl'] ?? '').toString(),
      genre: (json['genre'] ?? '').toString(),
      bookCategory: BookCategoryModel(
        id: categoryId,
        categoryName: categoryName,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'title': title,
        'coverImageUrl': bookimage,
        'genre': genre,
        'category': BookCategoryModel(
                id: bookCategory.id, categoryName: bookCategory.categoryName)
            .toJson(),
      };
}

class BookCategoryModel extends BookCategory {
  const BookCategoryModel({
    required super.id,
    required super.categoryName,
  });

  factory BookCategoryModel.fromJson(Map<String, dynamic> json) {
    return BookCategoryModel(
      id: (json['_id'] ?? '').toString(),
      categoryName: (json['name'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': categoryName,
      };
}
