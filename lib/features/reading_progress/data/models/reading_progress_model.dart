import '../../domain/entities/reading_progress_entity.dart';

class ReadingProgressModel extends ReadingProgressEntity {
  const ReadingProgressModel({
    required super.bookId,
    super.title,
    super.author,
    super.coverImageUrl,
    super.format,
    super.fileUrl,
    super.language,
    super.currentPage,
    super.totalPages,
    super.currentPart,
    super.totalParts,
    super.positionSeconds,
    super.locator,
    super.percentage,
    super.completed,
    super.lastReadAt,
  });

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static double _toDouble(dynamic v) {
    if (v is double) return v;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }

  factory ReadingProgressModel.fromJson(Map<String, dynamic> json) {
    return ReadingProgressModel(
      bookId: (json['bookId'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      author: (json['author'] ?? '').toString(),
      coverImageUrl: (json['coverImageUrl'] ?? '').toString(),
      format: (json['format'] ?? 'ebook').toString(),
      fileUrl: (json['fileUrl'] ?? '').toString(),
      language: (json['language'] ?? 'en').toString(),
      currentPage: _toInt(json['currentPage']),
      totalPages: _toInt(json['totalPages']),
      currentPart: _toInt(json['currentPart']),
      totalParts: _toInt(json['totalParts']),
      positionSeconds: _toInt(json['positionSeconds']),
      locator: (json['locator'] ?? '').toString(),
      percentage: _toDouble(json['percentage']),
      completed: json['completed'] == true,
      lastReadAt: json['lastReadAt'] != null
          ? DateTime.tryParse(json['lastReadAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookId': bookId,
      'title': title,
      'author': author,
      'coverImageUrl': coverImageUrl,
      'format': format,
      'fileUrl': fileUrl,
      'language': language,
      'currentPage': currentPage,
      'totalPages': totalPages,
      'currentPart': currentPart,
      'totalParts': totalParts,
      'positionSeconds': positionSeconds,
      'locator': locator,
      'percentage': percentage,
      'completed': completed,
      if (lastReadAt != null) 'lastReadAt': lastReadAt!.toIso8601String(),
    };
  }

  factory ReadingProgressModel.fromEntity(ReadingProgressEntity e) {
    return ReadingProgressModel(
      bookId: e.bookId,
      title: e.title,
      author: e.author,
      coverImageUrl: e.coverImageUrl,
      format: e.format,
      fileUrl: e.fileUrl,
      language: e.language,
      currentPage: e.currentPage,
      totalPages: e.totalPages,
      currentPart: e.currentPart,
      totalParts: e.totalParts,
      positionSeconds: e.positionSeconds,
      locator: e.locator,
      percentage: e.percentage,
      completed: e.completed,
      lastReadAt: e.lastReadAt,
    );
  }
}
