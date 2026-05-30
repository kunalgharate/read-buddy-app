import 'package:equatable/equatable.dart';
import 'package:read_buddy_app/features/explore/domain/entities/explore_category.dart';
import 'package:read_buddy_app/features/category_crud/domain/entity/category_enity.dart';

abstract class ExploreState extends Equatable {
  const ExploreState();

  @override
  List<Object?> get props => [];
}

class ExploreInitial extends ExploreState {}

class ExploreLoading extends ExploreState {}

class ExploreLoaded extends ExploreState {
  final List<CategoryEntity> parentCategories;
  final List<ExploreCategory> sections;
  final String? selectedCategoryId;
  
  const ExploreLoaded({
    required this.parentCategories,
    required this.sections,
    this.selectedCategoryId,
  });

  @override
  List<Object?> get props => [parentCategories, sections, selectedCategoryId];
}

class ExploreError extends ExploreState {
  final String message;
  const ExploreError(this.message);

  @override
  List<Object?> get props => [message];
}
