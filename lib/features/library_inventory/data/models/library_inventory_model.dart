import '../../domain/entities/library_inventory_entity.dart';

class LibraryInventoryModel extends LibraryInventoryEntity {
  const LibraryInventoryModel({
    required super.id,
    required super.libraryId,
    super.libraryName,
    required super.bookId,
    super.bookTitle,
    super.bookAuthor,
    super.bookCoverUrl,
    required super.variantId,
    super.variantLanguage,
    required super.formatType,
    required super.totalCopies,
    required super.availableCopies,
  });

  factory LibraryInventoryModel.fromJson(Map<String, dynamic> json) {
    // libraryId, bookId, variantId can be populated objects or plain strings
    final library = json['libraryId'];
    final book = json['bookId'];
    final variant = json['variantId'];

    return LibraryInventoryModel(
      id: json['_id']?.toString() ?? '',
      libraryId: library is Map ? library['_id']?.toString() ?? '' : library?.toString() ?? '',
      libraryName: library is Map ? library['name']?.toString() : null,
      bookId: book is Map ? book['_id']?.toString() ?? '' : book?.toString() ?? '',
      bookTitle: book is Map ? book['title']?.toString() : null,
      bookAuthor: book is Map ? book['author']?.toString() : null,
      bookCoverUrl: book is Map ? book['coverImageUrl']?.toString() : null,
      variantId: variant is Map ? variant['_id']?.toString() ?? '' : variant?.toString() ?? '',
      variantLanguage: variant is Map ? variant['language']?.toString() : null,
      formatType: json['formatType']?.toString() ?? 'hardcover',
      totalCopies: (json['totalCopies'] ?? 0) as int,
      availableCopies: (json['availableCopies'] ?? 0) as int,
    );
  }
}

class CityBookModel extends CityBookEntity {
  const CityBookModel({
    required super.bookId,
    required super.title,
    required super.author,
    super.coverImageUrl,
    required super.categories,
    required super.totalAvailable,
    required super.libraries,
  });

  factory CityBookModel.fromJson(Map<String, dynamic> json) {
    final libs = (json['libraries'] as List<dynamic>?)
            ?.map((l) => CityBookLibraryInfoModel.fromJson(
                l as Map<String, dynamic>))
            .toList() ??
        [];

    final cats = (json['categories'] as List<dynamic>?)
            ?.map((c) => c.toString())
            .toList() ??
        [];

    return CityBookModel(
      bookId: json['bookId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      author: json['author']?.toString() ?? '',
      coverImageUrl: json['coverImageUrl']?.toString(),
      categories: cats,
      totalAvailable: (json['totalAvailable'] ?? 0) as int,
      libraries: libs,
    );
  }
}

class CityBookLibraryInfoModel extends CityBookLibraryInfo {
  const CityBookLibraryInfoModel({
    required super.libraryId,
    required super.libraryName,
    required super.formatType,
    required super.availableCopies,
    required super.totalCopies,
  });

  factory CityBookLibraryInfoModel.fromJson(Map<String, dynamic> json) {
    return CityBookLibraryInfoModel(
      libraryId: json['libraryId']?.toString() ?? '',
      libraryName: json['libraryName']?.toString() ?? 'Unknown',
      formatType: json['formatType']?.toString() ?? 'hardcover',
      availableCopies: (json['availableCopies'] ?? 0) as int,
      totalCopies: (json['totalCopies'] ?? 0) as int,
    );
  }
}
