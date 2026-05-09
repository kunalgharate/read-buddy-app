import 'package:read_buddy_app/features/categories/domain/entities/book_category.dart';

abstract class CategoriesRepository {
  Future<List<BookCategory>> getCategories();
}
