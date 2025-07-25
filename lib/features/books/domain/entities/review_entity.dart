import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  final String id;
  final String reviewerName;
  final String? reviewerImageUrl;
  final double? rating;
  final String comment;

  const ReviewEntity({
    required this.id,
    required this.reviewerName,
    this.reviewerImageUrl,
    this.rating,
    required this.comment,
  });

  @override
  List<Object?> get props =>
      [id, reviewerName, reviewerImageUrl, rating, comment];
}
