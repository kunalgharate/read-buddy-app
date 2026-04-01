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
    String parentCategoryId = '',
  }) : super(
            id: id,
            title: title,
            parentCategory: category,
            parentCategoryId: parentCategoryId,
            imageUrl: imageUrl);

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final parent = json['parentCategoryId'];
    return CategoryModel(
      id: json['_id'] ?? '',
      title: json['name'] ?? '',
      category: parent is Map ? (parent['name'] ?? '') : '',
      parentCategoryId: parent is Map ? (parent['_id'] ?? '') : '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}
