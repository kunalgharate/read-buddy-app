// features/category_crud/domain/usecases/get_categories.dart
import 'package:injectable/injectable.dart';
import 'package:read_buddy_app/features/category_crud/domain/entity/category_enity.dart';

import '../repository/category_repository.dart';

@injectable
class GetCategoriesUsecase {
  final CategoryRepository repository;

  GetCategoriesUsecase(this.repository);

  Future<List<CategoryEntity>> call() => repository.getCategories();
}
