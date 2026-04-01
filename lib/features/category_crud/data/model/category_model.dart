import 'package:read_buddy_app/features/category_crud/domain/entity/category_enity.dart';

class CategoryModel extends CategoryEntity {
  final String id;
  final String title;
  final String category;
  final String imageUrl;

  CategoryModel({
    required this.id,
    required this.title,
    required this.category,
    required this.imageUrl,
  }) : super(
            id: id, title: title, parentCategory: category, imageUrl: imageUrl);

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'] ?? '',
      title: json['name'] ?? '',
      category: json['parentCategoryId'] != null
          ? json['parentCategoryId']['name'] ?? ''
          : '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}
