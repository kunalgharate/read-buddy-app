import 'package:equatable/equatable.dart';

abstract class ReviewEvent extends Equatable {
  const ReviewEvent();

  @override
  List<Object> get props => [];
}

class FetchReviews extends ReviewEvent {
  final String bookId;
  const FetchReviews(this.bookId);

  @override
  List<Object> get props => [bookId];
}
