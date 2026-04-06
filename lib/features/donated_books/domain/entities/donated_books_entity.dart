import 'package:equatable/equatable.dart';

class DonatedBooksEntity extends Equatable {
  final String? id; //used
  final String bookTitle; //used
  final String category; //currently not in API
  final String format; //used
  final String donorName; //used
  final String coverImageUrl; //optional
  final String createdAt; //used
  final String language; //used
  final String status;

  const DonatedBooksEntity({
    this.id,
    required this.bookTitle,
    required this.category,
    required this.format,
    required this.donorName,
    required this.coverImageUrl,
    required this.createdAt,
    required this.language,
    required this.status,
  });

  String get timeAgo {
    try {
      final diff = DateTime.now().difference(DateTime.parse(createdAt));
      if (diff.inDays >= 30) return '${(diff.inDays / 30).floor()}mo';
      if (diff.inDays >= 1) return '${diff.inDays}d';
      if (diff.inHours >= 1) return '${diff.inHours}H';
      return '${diff.inMinutes}m';
    } catch (_) {
      return '';
    }
  }

  @override
  List<Object?> get props => [
        id,
        bookTitle,
        category,
        format,
        donorName,
        coverImageUrl,
        createdAt,
        language,
        status,
      ];
}
