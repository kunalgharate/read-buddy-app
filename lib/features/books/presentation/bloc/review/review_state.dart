// lib/features/books/presentation/bloc/review/review_state.dart

import 'package:equatable/equatable.dart';
import '../../../domain/entities/review_entity.dart';

abstract class ReviewState extends Equatable {
  const ReviewState();

  @override
  List<Object> get props => [];
}

class ReviewInitial extends ReviewState {}

class ReviewLoading extends ReviewState {}

class ReviewLoaded extends ReviewState {
  final List<ReviewEntity> reviews;

  const ReviewLoaded(this.reviews);

  @override
  List<Object> get props => [reviews];
}

class ReviewError extends ReviewState {
  final String message;

  const ReviewError(this.message);

  @override
  List<Object> get props => [message];
}
