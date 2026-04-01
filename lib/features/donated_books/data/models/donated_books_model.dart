import '../../domain/entities/donated_books_entity.dart';

class DonatedBooksModel extends DonatedBooksEntity {
  DonatedBooksModel(
      {super.id,
      required super.bookTitle,
      required super.category,
      required super.format,
      required super.donorName,
      required super.coverImageUrl,
      required super.createdAt,
      required super.language,
      required super.status});

  factory DonatedBooksModel.fromJson(Map<String, dynamic> json) {
    final donation = json['donation'] as Map<String, dynamic>? ?? {};
    final donorId = donation['donorId'];
    final donorName = donorId is Map ? (donorId['name'] ?? '') : '';
    return DonatedBooksModel(
      id: donation['_id'],
      bookTitle: donation['title'] ?? '',
      category: donation['category'] ?? '',
      format: donation['format'] ?? '',
      donorName: donorName,
      coverImageUrl: donation['coverImageUrl'] ?? '',
      createdAt: donation['createdAt'] ?? '',
      language: donation['language'] ?? '',
      status: donation['status'] ?? '',
    );
  }
}
