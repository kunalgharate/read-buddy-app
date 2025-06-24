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
    required String parentCategory,
    File? image,
  }) {
    return repository.updateCategory(
        id: id, title: title, parentCategory: parentCategory, image: image);
  }
}
