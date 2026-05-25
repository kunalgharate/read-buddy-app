import 'package:equatable/equatable.dart';

class UserBookStatus extends Equatable {
  final String userId;
  final List<DonatedBook> donatedBooks;
  final List<RequestedBook> requestedBooks;
  final List<ReadingProgress> readingProgress;

  const UserBookStatus({
    required this.userId,
    required this.donatedBooks,
    required this.requestedBooks,
    required this.readingProgress,
  });

  @override
  List<Object?> get props =>
      [userId, donatedBooks, requestedBooks, readingProgress];
}

class DonatedBook extends Equatable {
  final String bookId;
  final String title;
  final String author;
  final String format;
  final String coverImageUrl;
  final String status;
  final DateTime donatedAt;
  final DateTime? deliveredAt;
  final BookRecipient? recipient;
  final String? trackingId;

  const DonatedBook({
    required this.bookId,
    required this.title,
    required this.author,
    required this.format,
    required this.coverImageUrl,
    required this.status,
    required this.donatedAt,
    this.deliveredAt,
    this.recipient,
    this.trackingId,
  });

  @override
  List<Object?> get props => [
        bookId,
        title,
        author,
        format,
        coverImageUrl,
        status,
        donatedAt,
        deliveredAt,
        recipient,
        trackingId,
      ];
}

class BookRecipient extends Equatable {
  final String name;
  final String city;

  const BookRecipient({
    required this.name,
    required this.city,
  });

  @override
  List<Object?> get props => [name, city];
}

class RequestedBook extends Equatable {
  final String requestId;
  final String title;
  final String author;
  final String format;
  final String status;
  final DateTime requestedAt;
  final DateTime? fulfilledAt;

  const RequestedBook({
    required this.requestId,
    required this.title,
    required this.author,
    required this.format,
    required this.status,
    required this.requestedAt,
    this.fulfilledAt,
  });

  @override
  List<Object?> get props =>
      [requestId, title, author, format, status, requestedAt, fulfilledAt];
}

class ReadingProgress extends Equatable {
  final String bookId;
  final String title;
  final String author;
  final String format;
  final int progressPercent;
  final DateTime lastReadAt;

  const ReadingProgress({
    required this.bookId,
    required this.title,
    required this.author,
    required this.format,
    required this.progressPercent,
    required this.lastReadAt,
  });

  @override
  List<Object?> get props =>
      [bookId, title, author, format, progressPercent, lastReadAt];
}
