import 'dart:io';

import 'package:read_buddy_app/features/category_crud/domain/repository/category_repository.dart';

class AddCategoryUsecase {
  final CategoryRepository repository;

  AddCategoryUsecase(this.repository);

  Future<void> call({
    required String title,
    required String parentCategory,
    required File image,
  }) {
    print("usecase ADDDDDDDDDDD calling");
    return repository.addCategory(
      title: title,
      parentCategory: parentCategory,
      image: image,
    );
  }
}
