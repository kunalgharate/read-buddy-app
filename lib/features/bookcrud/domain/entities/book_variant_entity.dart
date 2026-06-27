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

/// Represents a donation entry for physical book formats.
class DonationEntry extends Equatable {
  final String donorId;
  final String donorName;
  final int copiesDonated;
  final String? date;

  const DonationEntry({
    required this.donorId,
    required this.donorName,
    required this.copiesDonated,
    this.date,
  });

  @override
  List<Object?> get props => [donorId, donorName, copiesDonated, date];
}

/// A single format entry within a BookVariant.
/// Types: hardcover, paperback, ebook, audiobook, videobook
class BookFormatEntity extends Equatable {
  final String? id; // MongoDB _id for existing formats
  final String type;
  final String? donorId;
  final String? isbn;
  final int? copies;
  final int? availableCopies;
  final List<String> fileUrls; // multiple file URLs for ebook
  final String? fileUrl; // legacy single file URL
  final int? totalDuration; // seconds — for audiobook/videobook
  final List<MediaPartEntity> parts; // audiobook/videobook parts
  final List<DonationEntry> donations; // physical format donations

  const BookFormatEntity({
    this.id,
    required this.type,
    this.donorId,
    this.isbn,
    this.copies,
    this.availableCopies,
    this.fileUrls = const [],
    this.fileUrl,
    this.totalDuration,
    this.parts = const [],
    this.donations = const [],
  });

  @override
  List<Object?> get props => [
        id,
        type,
        donorId,
        isbn,
        copies,
        availableCopies,
        fileUrls,
        fileUrl,
        totalDuration,
        parts,
        donations,
      ];
}

/// A language variant of a Book.
/// Constraint: only one variant per (bookId + language) pair.
class BookVariantEntity extends Equatable {
  final String id;
  final String bookId;
  final String language;
  final String? donorId;
  final String? donorName;
  final List<BookFormatEntity> formats;

  const BookVariantEntity({
    required this.id,
    required this.bookId,
    required this.language,
    this.donorId,
    this.donorName,
    required this.formats,
  });

  @override
  List<Object?> get props =>
      [id, bookId, language, donorId, donorName, formats];
}
