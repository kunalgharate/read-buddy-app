import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/utils/secure_storage_utils.dart';
import '../../domain/entities/book_entity.dart';
import '../../domain/usecases/get_latest_books_usecase.dart';
import '../../domain/usecases/get_trending_books_usecase.dart';
import '../../domain/usecases/get_recommended_books_usecase.dart';
import 'home_book_event.dart';
import 'home_book_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetLatestBooksUseCase getLatestBooks;
  final GetTrendingBooksUseCase getTrendingBooks;
  final GetRecommendedBookUseCase getRecommendedBooks;
  final SecureStorageUtil secureStorage;

  HomeBloc({
    required this.getLatestBooks,
    required this.getTrendingBooks,
    required this.getRecommendedBooks,
    required this.secureStorage, // ← add
  }) : super(HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
  }

  Future<void> _onLoadHomeData(
    LoadHomeData event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    try {
      final results = await Future.wait([
        getLatestBooks(),
        getTrendingBooks(),
      ]);

      final recommended = await getRecommendedBooks();
      final user = await secureStorage.getUser(); // ← read user
      final isPrime = user?.isPrime ?? false; // ← extract isPrime

      if (kDebugMode) {
        print('✅ HomeBloc: All sections loaded | isPrime: $isPrime');
      }

      emit(HomeLoaded(
        latestBooks: results[0],
        trendingBooks: results[1],
        isPrime: isPrime,
        recommendedBooks: recommended,
      ));
    } catch (e) {
      if (kDebugMode) {
        print('❌ HomeBloc: Error → $e');
      }
      emit(HomeError(e.toString()));
    }
  }
}
