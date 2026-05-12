// features/category_crud/domain/usecases/delete_category.dart
import 'package:injectable/injectable.dart';
import '../repository/category_repository.dart';

@injectable
class DeleteCategoryUsecase {
  final CategoryRepository repository;

  DeleteCategoryUsecase(this.repository);

  Future<void> call(String id) => repository.deleteCategory(id);
}
