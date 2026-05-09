import 'package:read_buddy_app/features/categories/domain/entities/book_category.dart';
import 'package:read_buddy_app/features/categories/domain/repositories/categories_repository.dart';

class GetCategories {
  final CategoriesRepository repository;

  GetCategories({required this.repository});

  Future<List<BookCategory>> call() async {
    return await repository.getCategories();
  }
}
