// category_event.dart
part of 'category_bloc.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadCategories extends CategoryEvent {}

class AddCategoryEvent extends CategoryEvent {
  final String title;
  final String category;
  final File image;

  const AddCategoryEvent(
      {required this.title, required this.category, required this.image});

  @override
  List<Object?> get props => [title, category, image];
}

class UpdateCategoryEvent extends CategoryEvent {
  final String id;
  final String title;
  final String category;
  final File? image;

  const UpdateCategoryEvent(
      {required this.id,
      required this.title,
      required this.category,
      required this.image});

  @override
  List<Object?> get props => [id, title, category, image];
}

class DeleteCategoryEvent extends CategoryEvent {
  final String id;

  const DeleteCategoryEvent(this.id);

  @override
  List<Object?> get props => [id];
}
