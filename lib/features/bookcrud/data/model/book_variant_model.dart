import '../../domain/entities/book_variant_entity.dart';
import 'media_part_model.dart';

class DonationEntryModel extends DonationEntry {
  const DonationEntryModel({
    required super.donorId,
    required super.donorName,
    required super.copiesDonated,
    super.date,
  });

  factory DonationEntryModel.fromJson(Map<String, dynamic> json) {
    // donorId can be a populated object { _id, name, email } or a plain string
    final donorData = json['donorId'];
    String donorId = '';
    String donorName = '';
    if (donorData is Map<String, dynamic>) {
      donorId = donorData['_id'] ?? '';
      donorName = donorData['name'] ?? '';
    } else if (donorData is String) {
      donorId = donorData;
      donorName = json['donorName'] ?? '';
    }

    return DonationEntryModel(
      donorId: donorId,
      donorName: donorName,
      copiesDonated: json['copiesDonated'] ?? 1,
      date: json['donatedOn'] ?? json['date'],
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'donorId': donorId,
      'donorName': donorName,
      'copiesDonated': copiesDonated,
    };
    if (date != null) map['date'] = date;
    return map;
  }

  factory DonationEntryModel.fromEntity(DonationEntry entity) {
    return DonationEntryModel(
      donorId: entity.donorId,
      donorName: entity.donorName,
      copiesDonated: entity.copiesDonated,
      date: entity.date,
    );
  }
}

class BookFormatModel extends BookFormatEntity {
  const BookFormatModel({
    super.id,
    required super.type,
    super.donorId,
    super.isbn,
    super.copies,
    super.availableCopies,
    super.fileUrls,
    super.fileUrl,
    super.totalDuration,
    super.parts,
    super.donations,
  });

  factory BookFormatModel.fromJson(Map<String, dynamic> json) {
    // donorId can be a populated object { _id, name, email } or a plain string
    final donorData = json['donorId'];
    String? donorId;
    if (donorData is Map<String, dynamic>) {
      donorId = donorData['_id'];
    } else if (donorData is String) {
      donorId = donorData;
    }

    // Parse fileUrls array
    List<String> fileUrls = [];
    if (json['fileUrls'] is List) {
      fileUrls = (json['fileUrls'] as List).map((e) => e.toString()).toList();
    }

    // Legacy single fileUrl fallback
    String? fileUrl = json['fileUrl'];
    if ((fileUrl == null || fileUrl.isEmpty) && fileUrls.isNotEmpty) {
      fileUrl = fileUrls.first;
    }

    // Parse donations array
    List<DonationEntryModel> donations = [];
    if (json['donations'] is List) {
      donations = (json['donations'] as List)
          .map((d) => DonationEntryModel.fromJson(d))
          .toList();
    }

    return BookFormatModel(
      id: json['_id'],
      type: json['type'] ?? '',
      donorId: donorId,
      isbn: json['isbn'],
      copies: json['copies'],
      availableCopies: json['availableCopies'],
      fileUrls: fileUrls,
      fileUrl: fileUrl,
      totalDuration: json['totalDuration'],
      parts: (json['parts'] as List?)
              ?.map((p) => MediaPartModel.fromJson(p))
              .toList() ??
          const [],
      donations: donations,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'type': type,
    };
    if (donorId != null) map['donorId'] = donorId;
    if (isbn != null) map['isbn'] = isbn;
    if (copies != null) map['copies'] = copies;
    if (availableCopies != null) map['availableCopies'] = availableCopies;
    if (fileUrls.isNotEmpty) map['fileUrls'] = fileUrls;
    if (fileUrl != null) map['fileUrl'] = fileUrl;
    if (totalDuration != null) map['totalDuration'] = totalDuration;
    if (parts.isNotEmpty) {
      map['parts'] =
          parts.map((p) => MediaPartModel.fromEntity(p).toJson()).toList();
    }
    if (donations.isNotEmpty) {
      map['donations'] = donations
          .map((d) => DonationEntryModel.fromEntity(d).toJson())
          .toList();
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
      availableCopies: entity.availableCopies,
      fileUrls: entity.fileUrls,
      fileUrl: entity.fileUrl,
      totalDuration: entity.totalDuration,
      parts: entity.parts,
      donations: entity.donations,
    );
  }
}

class BookVariantModel extends BookVariantEntity {
  const BookVariantModel({
    required super.id,
    required super.bookId,
    required super.language,
    super.donorId,
    super.donorName,
    required super.formats,
  });

  factory BookVariantModel.fromJson(Map<String, dynamic> json) {
    // donorId can be a populated object { _id, name, email } or a plain string
    final donorData = json['donorId'];
    String? donorId;
    String? donorName;
    if (donorData is Map<String, dynamic>) {
      donorId = donorData['_id'];
      donorName = donorData['name'];
    } else if (donorData is String) {
      donorId = donorData;
    }

    return BookVariantModel(
      id: json['_id'] ?? json['id'] ?? '',
      bookId: json['bookId'] is Map
          ? (json['bookId']['_id'] ?? '')
          : (json['bookId'] ?? ''),
      language: json['language'] ?? '',
      donorId: donorId,
      donorName: donorName,
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
      donorName: entity.donorName,
      formats: entity.formats,
    );
  }
}
