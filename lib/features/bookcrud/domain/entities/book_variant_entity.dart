import 'package:equatable/equatable.dart';

/// Represents a single part (chapter/segment) of an audiobook or videobook.
class MediaPartEntity extends Equatable {
  final int partNumber;
  final String title;
  final String? audioUrl;
  final String? videoUrl;
  final int duration; // seconds

  const MediaPartEntity({
    required this.partNumber,
    required this.title,
    this.audioUrl,
    this.videoUrl,
    required this.duration,
  });

  @override
  List<Object?> get props => [partNumber, title, audioUrl, videoUrl, duration];
}

/// A single format entry within a BookVariant.
/// Types: hardcover, paperback, ebook, audiobook, videobook
class BookFormatEntity extends Equatable {
  final String? id; // MongoDB _id for existing formats
  final String type;
  final String? donorId;
  final String? isbn;
  final int? copies;
  final bool? available;
  final String? fileUrl;
  final int? totalDuration; // seconds — for audiobook/videobook
  final List<MediaPartEntity> parts; // audiobook/videobook parts

  const BookFormatEntity({
    this.id,
    required this.type,
    this.donorId,
    this.isbn,
    this.copies,
    this.available,
    this.fileUrl,
    this.totalDuration,
    this.parts = const [],
  });

  @override
  List<Object?> get props => [
        id,
        type,
        donorId,
        isbn,
        copies,
        available,
        fileUrl,
        totalDuration,
        parts,
      ];
}

/// A language variant of a Book.
/// Constraint: only one variant per (bookId + language) pair.
class BookVariantEntity extends Equatable {
  final String id;
  final String bookId;
  final String language;
  final String? donorId;
  final List<BookFormatEntity> formats;

  const BookVariantEntity({
    required this.id,
    required this.bookId,
    required this.language,
    this.donorId,
    required this.formats,
  });

  @override
  List<Object?> get props => [id, bookId, language, donorId, formats];
}
