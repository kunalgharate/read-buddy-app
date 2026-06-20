import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/features/category_crud/data/datasources/category_remote_dataresources.dart';
import 'package:read_buddy_app/features/bookcrud/data/dataresources/bookCrud_remote_resources.dart';
import 'package:read_buddy_app/features/explore/domain/entities/explore_category.dart';
import 'explore_event.dart';
import 'explore_state.dart';

class ExploreBloc extends Bloc<ExploreEvent, ExploreState> {
  final CategoryRemoteDataSource categoryDataSource;
  final BookCrudRemoteDataSource bookDataSource;

  ExploreBloc({
    required this.categoryDataSource,
    required this.bookDataSource,
  }) : super(ExploreInitial()) {
    on<LoadExploreData>(_onLoadExploreData);
    on<SelectCategory>(_onSelectCategory);
  }

  Future<void> _onLoadExploreData(
    LoadExploreData event,
    Emitter<ExploreState> emit,
  ) async {
    emit(ExploreLoading());
    try {
      final categories = await categoryDataSource.getCategories();
      final books = await bookDataSource.getBooks();

      // Filter parent categories
      final parentCategories = categories.where((c) => c.parentCategoryName == null).toList();

      // Group books by category
      final sections = <ExploreCategory>[];
      for (final category in categories) {
        final categoryBooks = books.where((b) => b.categoryId == category.id).toList();
        if (categoryBooks.isNotEmpty) {
          sections.add(ExploreCategory(
            category: category,
            books: categoryBooks,
          ));
        }
      }

      emit(ExploreLoaded(
        parentCategories: parentCategories,
        sections: sections,
      ));
    } catch (e) {
      emit(ExploreError(e.toString()));
    }
  }

  void _onSelectCategory(
    SelectCategory event,
    Emitter<ExploreState> emit,
  ) {
    if (state is ExploreLoaded) {
      final currentState = state as ExploreLoaded;
      emit(ExploreLoaded(
        parentCategories: currentState.parentCategories,
        sections: currentState.sections,
        selectedCategoryId: event.categoryId,
      ));
    }
  }
}
