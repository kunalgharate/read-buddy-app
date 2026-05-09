import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:read_buddy_app/features/categories/data/models/book_category_model.dart';

abstract class CategoriesLocalDataSource {
  Future<List<BookCategoryModel>> getCategories();
}

class CategoriesLocalDataSourceImpl implements CategoriesLocalDataSource {
  @override
  Future<List<BookCategoryModel>> getCategories() async {
    try {
      final String response =
          await rootBundle.loadString('assets/mock_data/book_categories.json');
      final Map<String, dynamic> data = json.decode(response);
      final List<dynamic> categoriesJson = data['categories'] as List<dynamic>;

      return categoriesJson
          .map((json) =>
              BookCategoryModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }
}
