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
    final created = DateTime.tryParse(createdAt);
    if (created == null) return '';

    final now = DateTime.now();
    if (created.isAfter(now)) return '0m';

    final diff = now.difference(created);
    if (diff.inDays >= 30) return '${(diff.inDays / 30).floor()}mo';
    if (diff.inDays >= 1) return '${diff.inDays}d';
    if (diff.inHours >= 1) return '${diff.inHours}h';
    return '${diff.inMinutes}m';
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
