// features/category_crud/data/repositories/category_repository_impl.dart
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:read_buddy_app/features/category_crud/data/datasources/category_remote_dataresources.dart';
import 'package:read_buddy_app/features/category_crud/domain/entity/category_enity.dart';
import 'package:read_buddy_app/features/category_crud/domain/repository/category_repository.dart';

@Injectable(as: CategoryRepository)
class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource remoteDataSource;

  CategoryRepositoryImpl(this.remoteDataSource);

  // @override
  // Future<List<CategoryEntity>> getCategories() async {
  //   return await remoteDataSource.getCategories();
  // }

  @override
  Future<List<CategoryEntity>> getCategories() async {
    final models = await remoteDataSource.getCategories();
    return models.cast<CategoryEntity>();
  }

  @override
  Future<void> addCategory({
    required String title,
    required String description,
    String? parentCategoryId,
    required File image,
  }) async {
    print("AAAAAAAAAAdddddd catat implll $parentCategoryId");
    await remoteDataSource.addCategory(
      title: title,
      description: description,
      parentCategoryId: parentCategoryId,
      image: image,
    );
  }

  @override
  Future<void> updateCategory({
    required String id,
    required String title,
    required String description,
    required File? image,
  }) async {
    await remoteDataSource.updateCategory(
      id: id,
      title: title,
      description: description,
      image: image,
    );
  }

  @override
  Future<void> deleteCategory(String id) async {
    await remoteDataSource.deleteCategory(id);
  }
}
