import 'package:equatable/equatable.dart';
import 'package:read_buddy_app/features/home/domain/entities/book_entity.dart';

abstract class HomeMainState extends Equatable {
  const HomeMainState();
  @override
  List<Object> get props => [];
}

class HomeMainInitial extends HomeMainState {}

class HomeMainLoading extends HomeMainState {}

class HomeMainLoaded extends HomeMainState {
  final List<LatestBookEntity> latestBooks;
  final List<RecommendedBookCardEntity> recommendedBooks;
  final List<StatEntity> stats;

  const HomeMainLoaded({
    required this.latestBooks,
    required this.recommendedBooks,
    required this.stats,
  });

  @override
  List<Object> get props => [latestBooks, recommendedBooks, stats];
}

class HomeMainError extends HomeMainState {
  final String message;
  const HomeMainError(this.message);

  @override
  List<Object> get props => [message];
}
