import 'package:equatable/equatable.dart';

/// A single inventory record: "Library X has Y copies of Book Z (variant, format)."
class LibraryInventoryEntity extends Equatable {
  final String id;
  final String libraryId;
  final String? libraryName;
  final String bookId;
  final String? bookTitle;
  final String? bookAuthor;
  final String? bookCoverUrl;
  final String variantId;
  final String? variantLanguage;
  final String formatType; // 'hardcover' or 'paperback'
  final int totalCopies;
  final int availableCopies;

  const LibraryInventoryEntity({
    required this.id,
    required this.libraryId,
    this.libraryName,
    required this.bookId,
    this.bookTitle,
    this.bookAuthor,
    this.bookCoverUrl,
    required this.variantId,
    this.variantLanguage,
    required this.formatType,
    required this.totalCopies,
    required this.availableCopies,
  });

  int get borrowedCount => totalCopies - availableCopies;
  bool get isAvailable => availableCopies > 0;

  @override
  List<Object?> get props => [
        id,
        libraryId,
        bookId,
        variantId,
        formatType,
        totalCopies,
        availableCopies,
      ];
}

/// Aggregated book availability for city-based browsing.
/// One entry per book, with per-library breakdown.
class CityBookEntity extends Equatable {
  final String bookId;
  final String title;
  final String author;
  final String? coverImageUrl;
  final List<String> categories;
  final int totalAvailable;
  final List<CityBookLibraryInfo> libraries;

  const CityBookEntity({
    required this.bookId,
    required this.title,
    required this.author,
    this.coverImageUrl,
    required this.categories,
    required this.totalAvailable,
    required this.libraries,
  });

  bool get isAvailable => totalAvailable > 0;

  @override
  List<Object?> get props => [bookId, totalAvailable];
}

class CityBookLibraryInfo extends Equatable {
  final String libraryId;
  final String libraryName;
  final String formatType;
  final int availableCopies;
  final int totalCopies;

  const CityBookLibraryInfo({
    required this.libraryId,
    required this.libraryName,
    required this.formatType,
    required this.availableCopies,
    required this.totalCopies,
  });

  @override
  List<Object?> get props =>
      [libraryId, formatType, availableCopies, totalCopies];
}
