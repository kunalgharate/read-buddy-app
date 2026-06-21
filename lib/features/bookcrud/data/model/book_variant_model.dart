import '../../domain/entities/book_variant_entity.dart';
import 'media_part_model.dart';

class BookFormatModel extends BookFormatEntity {
  const BookFormatModel({
    super.id,
    required super.type,
    super.donorId,
    super.isbn,
    super.copies,
    super.available,
    super.fileUrl,
    super.totalDuration,
    super.parts,
  });

  factory BookFormatModel.fromJson(Map<String, dynamic> json) {
    return BookFormatModel(
      id: json['_id'],
      type: json['type'] ?? '',
      donorId: json['donorId'],
      isbn: json['isbn'],
      copies: json['copies'],
      available: json['available'],
      fileUrl: json['fileUrl'],
      totalDuration: json['totalDuration'],
      parts: (json['parts'] as List?)
              ?.map((p) => MediaPartModel.fromJson(p))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'type': type,
    };
    if (donorId != null) map['donorId'] = donorId;
    if (isbn != null) map['isbn'] = isbn;
    if (copies != null) map['copies'] = copies;
    if (available != null) map['available'] = available;
    if (fileUrl != null) map['fileUrl'] = fileUrl;
    if (totalDuration != null) map['totalDuration'] = totalDuration;
    if (parts.isNotEmpty) {
      map['parts'] =
          parts.map((p) => MediaPartModel.fromEntity(p).toJson()).toList();
    }
    return map;
  }

  factory BookFormatModel.fromEntity(BookFormatEntity entity) {
    return BookFormatModel(
      id: entity.id,
      type: entity.type,
      donorId: entity.donorId,
      isbn: entity.isbn,
      copies: entity.copies,
      available: entity.available,
      fileUrl: entity.fileUrl,
      totalDuration: entity.totalDuration,
      parts: entity.parts,
    );
  }
}

class BookVariantModel extends BookVariantEntity {
  const BookVariantModel({
    required super.id,
    required super.bookId,
    required super.language,
    super.donorId,
    required super.formats,
  });

  factory BookVariantModel.fromJson(Map<String, dynamic> json) {
    return BookVariantModel(
      id: json['_id'] ?? json['id'] ?? '',
      bookId: json['bookId'] is Map
          ? (json['bookId']['_id'] ?? '')
          : (json['bookId'] ?? ''),
      language: json['language'] ?? '',
      donorId: json['donorId'],
      formats: (json['formats'] as List? ?? [])
          .map((item) => BookFormatModel.fromJson(item))
          .toList(),
    );
  }

  /// Serializes for POST /api/book-variants (create).
  Map<String, dynamic> toJson() {
    return {
      'bookId': bookId,
      'language': language,
      if (donorId != null) 'donorId': donorId,
      'formats': formats
          .map((item) => BookFormatModel.fromEntity(item).toJson())
          .toList(),
    };
  }

  factory BookVariantModel.fromEntity(BookVariantEntity entity) {
    return BookVariantModel(
      id: entity.id,
      bookId: entity.bookId,
      language: entity.language,
      donorId: entity.donorId,
      formats: entity.formats,
    );
  }
}
