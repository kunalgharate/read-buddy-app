import 'package:read_buddy_app/features/categories/domain/entities/book_category.dart';

class BookCategoryModel extends BookCategory {
  const BookCategoryModel({
    required super.id,
    required super.title,
    required super.description,
    required super.imageUrl,
    super.parentCategoryName,
    required super.bookCount,
  });

  factory BookCategoryModel.fromJson(Map<String, dynamic> json) {
    return BookCategoryModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String,
      parentCategoryName: json['parent_category_name'] as String?,
      bookCount: json['book_count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'parent_category_name': parentCategoryName,
      'book_count': bookCount,
    };
  }
}
