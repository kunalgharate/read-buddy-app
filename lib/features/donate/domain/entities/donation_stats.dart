import 'package:equatable/equatable.dart';

class DonationStats extends Equatable {
  final int booksDonated;
  final int studentsHelped;
  final List<BookStatusItem> bookStatusList;

  const DonationStats({
    required this.booksDonated,
    required this.studentsHelped,
    required this.bookStatusList,
  });

  @override
  List<Object?> get props => [
        booksDonated,
        studentsHelped,
        bookStatusList,
      ];
}

class BookStatusItem extends Equatable {
  final String id;
  final String title;
  final String format;
  final String status;
  final String? condition;
  final String? fulfillmentType;
  final String? createdAt;
  final String? categoryName;
  final String? coverImageUrl;

  const BookStatusItem({
    required this.id,
    required this.title,
    required this.format,
    required this.status,
    this.condition,
    this.fulfillmentType,
    this.createdAt,
    this.categoryName,
    this.coverImageUrl,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        format,
        status,
        condition,
        fulfillmentType,
        createdAt,
        categoryName,
        coverImageUrl,
      ];
}
