/// eBook domain entities — pure Dart, no framework dependencies.
library;

enum EBookType { single, multiChapter }

enum EBookFormat { pdf, epub }

class EBookLanguage {
  final String code;
  final String name;

  const EBookLanguage({
    required this.code,
    required this.name,
  });
}

class EBookChapter {
  final String id;
  final String title;
  final int chapterNumber;
  final Map<String, String> urlsByLanguage;
  final EBookFormat format;

  const EBookChapter({
    required this.id,
    required this.title,
    required this.chapterNumber,
    required this.urlsByLanguage,
    this.format = EBookFormat.pdf,
  });
}

class EBook {
  final String id;
  final String bookId;
  final String title;
  final String coverUrl;
  final String author;
  final EBookType type;
  final List<EBookChapter> chapters;
  final List<EBookLanguage> availableLanguages;

  const EBook({
    required this.id,
    required this.bookId,
    required this.title,
    required this.coverUrl,
    required this.author,
    required this.type,
    required this.chapters,
    required this.availableLanguages,
  });
}
