import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:read_buddy_app/features/category_crud/domain/entity/category_enity.dart';
import 'package:read_buddy_app/features/category_crud/domain/usecases/add_categories.dart';
import 'package:read_buddy_app/features/category_crud/domain/usecases/dele_category.dart';
import 'package:read_buddy_app/features/category_crud/domain/usecases/get_caategories.dart';

import 'package:read_buddy_app/features/category_crud/domain/usecases/update_category.dart';

part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetCategoriesUsecase getCategories;
  final AddCategoryUsecase addCategory;
  final UpdateCategoryUsecase updateCategory;
  final DeleteCategoryUsecase deleteCategory;

  CategoryBloc({
    required this.getCategories,
    required this.addCategory,
    required this.updateCategory,
    required this.deleteCategory,
  }) : super(CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<AddCategoryEvent>(_onAddCategory);
    on<UpdateCategoryEvent>(_onUpdateCategory);
    on<DeleteCategoryEvent>(_onDeleteCategory);
  }

  Future<void> _onLoadCategories(
      LoadCategories event, Emitter<CategoryState> emit) async {
    emit(CategoryLoading());
    try {
      final categories = await getCategories();
      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryError('Failed to load categories: ${e.toString()}'));
    }
  }

  Future<void> _onAddCategory(
      AddCategoryEvent event, Emitter<CategoryState> emit) async {
    try {
      await addCategory.call(
        title: event.title,
        description: event.description,
        parentCategoryId: event.parentCategoryId,
        image: event.image,
      );
      emit(CategorySuccess());
      add(LoadCategories());
    } catch (e) {
      emit(CategoryError('Failed to add category: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateCategory(
      UpdateCategoryEvent event, Emitter<CategoryState> emit) async {
    try {
      await updateCategory(
        id: event.id,
        title: event.title,
        description: event.description,
        parentCategoryId: event.parentCategoryId,
        image: event.image,
      );
      emit(CategorySuccess());
      add(LoadCategories());
    } catch (e) {
      emit(CategoryError('Failed to update category: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteCategory(
      DeleteCategoryEvent event, Emitter<CategoryState> emit) async {
    try {
      await deleteCategory(event.id);
      add(LoadCategories());
    } catch (e) {
      emit(CategoryError('Failed to delete category: ${e.toString()}'));
    }
  }
}
