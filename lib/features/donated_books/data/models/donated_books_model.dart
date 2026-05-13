import 'package:read_buddy_app/features/donated_books/domain/entities/donated_books_entity.dart';

class DonatedBooksModel extends DonatedBooksEntity {
  const DonatedBooksModel({
    super.id,
    required super.bookTitle,
    required super.category,
    required super.format,
    required super.donorName,
    required super.coverImageUrl,
    required super.createdAt,
    required super.language,
    required super.status,
  });

  factory DonatedBooksModel.fromJson(Map<String, dynamic> json) {
    // Handle both nested (with 'donation' key) and flat response structures
    final donation = json.containsKey('donation')
        ? json['donation'] as Map<String, dynamic>
        : json;

    // donorId can be String (ID) or Map (object with name)
    final donorData = donation['donorId'];
    String donorName = '';
    if (donorData is Map<String, dynamic>) {
      donorName = donorData['name']?.toString() ?? '';
    }

    // category can be String (ID) or Map (object with name)
    final categoryData = donation['category'];
    String categoryName = '';
    if (categoryData is Map<String, dynamic>) {
      categoryName = categoryData['name']?.toString() ?? '';
    } else if (categoryData != null) {
      categoryName = categoryData.toString();
    }

    return DonatedBooksModel(
      id: donation['_id']?.toString(),
      bookTitle: donation['title']?.toString() ?? '',
      category: categoryName,
      format: donation['format']?.toString() ?? '',
      donorName: donorName,
      coverImageUrl: donation['coverImageUrl']?.toString() ?? '',
      createdAt: donation['createdAt']?.toString() ?? '',
      language: donation['language']?.toString() ?? '',
      status: donation['status']?.toString() ?? '',
    );
  }
}
