import '../../domain/entities/donated_books_entity.dart';

class DonatedBooksModel extends DonatedBooksEntity {
  DonatedBooksModel({
    super.id,
    required super.bookTitle,
    required super.category,
    required super.format,
    required super.donorName,
    required super.coverImageUrl,
    required super.createdAt,
    required super.language,
    required super.status
  });

  factory DonatedBooksModel.fromJson(Map<String, dynamic> json){
    return DonatedBooksModel(
      id: json['donation']['_id'],
      bookTitle: json['donation']['title'] ?? '',
      category: json['donation']['category'] ?? '',
      format: json['donation']['format'] ?? '',
      donorName: json['donation']['donorId']['name'] ?? '',
      coverImageUrl: json['donation']['coverImageUrl'] ?? '',
      createdAt: json['donation']['createdAt'] ?? '',
      language: json['donation']['language'] ?? '',
      status: json['donation']['status'] ?? '',
    );
  }

}
