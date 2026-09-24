import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  final String? id;
  final String bookId;
  final String userId;
  final String userName;
  final String userAvatar;
  final int rating;
  final String title;
  final String comment;
  final int helpfulCount;
  final String createdAt;
  final String updatedAt;

  const ReviewEntity({
    this.id,
    required this.bookId,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    this.title = '',
    required this.comment,
    this.helpfulCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        bookId,
        userId,
        userName,
        userAvatar,
        rating,
        title,
        comment,
        helpfulCount,
        createdAt,
        updatedAt,
      ];
}
