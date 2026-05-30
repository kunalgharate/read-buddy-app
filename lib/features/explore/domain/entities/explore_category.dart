import 'package:equatable/equatable.dart';
import 'package:read_buddy_app/features/category_crud/domain/entity/category_enity.dart';
import 'package:read_buddy_app/features/bookcrud/domain/entities/book_crud.dart';

class ExploreCategory extends Equatable {
  final CategoryEntity category;
  final List<BookCrudEntity> books;

  const ExploreCategory({
    required this.category,
    required this.books,
  });

  @override
  List<Object?> get props => [category, books];
}
