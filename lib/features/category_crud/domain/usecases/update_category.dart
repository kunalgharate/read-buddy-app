// features/category_crud/domain/usecases/update_category.dart
import 'dart:io';
import 'package:injectable/injectable.dart';
import '../repository/category_repository.dart';

@injectable
class UpdateCategoryUsecase {
  final CategoryRepository repository;

  UpdateCategoryUsecase(this.repository);

  Future<void> call({
    required String id,
    required String title,
    required String description,
    String? parentCategoryId,
    File? image,
  }) {
    return repository.updateCategory(
        id: id, title: title, description: description, parentCategoryId: parentCategoryId, image: image);
  }
}
