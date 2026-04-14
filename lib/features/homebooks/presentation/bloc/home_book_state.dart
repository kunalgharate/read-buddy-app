import '../../domain/entities/book_entity.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<BookEntity> trendingBooks;
  final List<BookEntity> recommendedBooks;
  final List<BookEntity> latestBooks;
  final bool isPrime;

  HomeLoaded({
    required this.trendingBooks,
    required this.recommendedBooks,
    required this.latestBooks,
    required this.isPrime,
  });
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}
