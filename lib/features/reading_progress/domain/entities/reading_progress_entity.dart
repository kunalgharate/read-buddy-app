/// Domain entity describing a user's saved position within a book so that
/// reading / listening / watching can be resumed — including after changing
/// the TTS voice/language or switching devices.
class ReadingProgressEntity {
  final String bookId;
  final String title;
  final String author;
  final String coverImageUrl;

  /// ebook | audiobook | videobook
  final String format;

  /// URL of the opened file/part (used to resume straight into the reader).
  final String fileUrl;

  /// TTS voice/language selected for this book.
  final String language;

  final int currentPage;
  final int totalPages;
  final int currentPart;
  final int totalParts;
  final int positionSeconds;

  /// EPUB CFI or any opaque resume locator.
  final String locator;

  /// 0..100
  final double percentage;
  final bool completed;
  final DateTime? lastReadAt;

  const ReadingProgressEntity({
    required this.bookId,
    this.title = '',
    this.author = '',
    this.coverImageUrl = '',
    this.format = 'ebook',
    this.fileUrl = '',
    this.language = 'en',
    this.currentPage = 0,
    this.totalPages = 0,
    this.currentPart = 0,
    this.totalParts = 0,
    this.positionSeconds = 0,
    this.locator = '',
    this.percentage = 0,
    this.completed = false,
    this.lastReadAt,
  });

  ReadingProgressEntity copyWith({
    String? title,
    String? author,
    String? coverImageUrl,
    String? format,
    String? fileUrl,
    String? language,
    int? currentPage,
    int? totalPages,
    int? currentPart,
    int? totalParts,
    int? positionSeconds,
    String? locator,
    double? percentage,
    bool? completed,
    DateTime? lastReadAt,
  }) {
    return ReadingProgressEntity(
      bookId: bookId,
      title: title ?? this.title,
      author: author ?? this.author,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      format: format ?? this.format,
      fileUrl: fileUrl ?? this.fileUrl,
      language: language ?? this.language,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      currentPart: currentPart ?? this.currentPart,
      totalParts: totalParts ?? this.totalParts,
      positionSeconds: positionSeconds ?? this.positionSeconds,
      locator: locator ?? this.locator,
      percentage: percentage ?? this.percentage,
      completed: completed ?? this.completed,
      lastReadAt: lastReadAt ?? this.lastReadAt,
    );
  }

  /// Human-friendly progress label for the "Continue reading" card.
  String get progressLabel {
    switch (format) {
      case 'videobook':
      case 'audiobook':
        if (totalParts > 0) {
          return 'Chapter ${currentPart + 1} of $totalParts';
        }
        return '${percentage.round()}% complete';
      case 'ebook':
      default:
        if (totalPages > 0) {
          return 'Page $currentPage of $totalPages';
        }
        return '${percentage.round()}% complete';
    }
  }
}
