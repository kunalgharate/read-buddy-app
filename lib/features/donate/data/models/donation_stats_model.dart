import 'package:read_buddy_app/features/donate/domain/entities/donation_stats.dart';

class BookStatusItemModel extends BookStatusItem {
  const BookStatusItemModel({
    required super.id,
    required super.title,
    required super.format,
    required super.status,
    super.condition,
    super.fulfillmentType,
    super.createdAt,
    super.categoryName,
    super.coverImageUrl,
  });

  factory BookStatusItemModel.fromJson(Map<String, dynamic> json) {
    final categoryData = json['category'];
    String? categoryName;
    if (categoryData is Map<String, dynamic>) {
      categoryName = categoryData['name']?.toString();
    } else if (categoryData != null) {
      categoryName = categoryData.toString();
    }

    return BookStatusItemModel(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      title: (json['title'] ?? json['bookTitle'] ?? json['bookName'])
              ?.toString() ??
          '',
      format: json['format']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      condition: json['condition']?.toString(),
      fulfillmentType: json['fulfillmentType']?.toString(),
      createdAt: json['createdAt']?.toString(),
      categoryName: categoryName,
      coverImageUrl: json['coverImageUrl']?.toString(),
    );
  }
}

class DonationStatsModel extends DonationStats {
  const DonationStatsModel({
    required super.booksDonated,
    required super.studentsHelped,
    required super.bookStatusList,
  });

  factory DonationStatsModel.fromJson(Map<String, dynamic> json) {
    // API might return strings like "10", "00" or nested under 'impact'
    final impact = json['impact'] as Map<String, dynamic>? ?? json;

    final booksDonated = int.tryParse(
          impact['booksDonated']?.toString() ?? '0',
        ) ??
        0;

    final studentsHelped = int.tryParse(
          impact['studentsHelped']?.toString() ?? '0',
        ) ??
        0;

    final rawList = json['bookStatusList'] as List<dynamic>? ??
        json['donatedBooksList'] as List<dynamic>? ??
        [];
    final bookStatusList = rawList
        .map((e) => BookStatusItemModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return DonationStatsModel(
      booksDonated: booksDonated,
      studentsHelped: studentsHelped,
      bookStatusList: bookStatusList,
    );
  }
}
