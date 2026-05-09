import 'package:read_buddy_app/features/categories/domain/entities/book_category.dart';
import 'package:read_buddy_app/features/categories/domain/repositories/categories_repository.dart';
import 'package:read_buddy_app/features/categories/data/datasources/categories_local_datasource.dart';

class CategoriesRepositoryImpl implements CategoriesRepository {
  final CategoriesLocalDataSource localDataSource;

  CategoriesRepositoryImpl({required this.localDataSource});

  @override
  Future<List<BookCategory>> getCategories() async {
    return await localDataSource.getCategories();
  }
}
