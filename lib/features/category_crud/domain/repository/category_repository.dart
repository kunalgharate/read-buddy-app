// domain/repositories/category_repository.dart
import 'package:read_buddy_app/features/category_crud/domain/entity/category_enity.dart';

import 'dart:io';

abstract class CategoryRepository {
  Future<List<CategoryEntity>> getCategories();
  Future<void> addCategory({
    required String title,
    required String description,
    String? parentCategoryId,
    required File image,
  });
  Future<void> updateCategory({
    required String id,
    required String title,
    required String description,
    String? parentCategoryId,
    required File? image,
  });
  Future<void> deleteCategory(String id);
}
