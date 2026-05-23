import 'package:read_buddy_app/features/category_crud/domain/entity/category_enity.dart';

class CategoryModel extends CategoryEntity {
  CategoryModel({
    required super.id,
    required super.title,
    super.parentCategoryName,
    required super.imageUrl,
    super.description,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final parent = json['parentCategoryId'];
    final imageUrl = (json['imageUrl'] ?? '').toString();

    return CategoryModel(
      id: json['_id'] ?? '',
      title: json['name'] ?? '',
      parentCategoryName: parent is Map ? parent['name'] : null,
      imageUrl: imageUrl,
      description: json['description'],
    );
  }
}
