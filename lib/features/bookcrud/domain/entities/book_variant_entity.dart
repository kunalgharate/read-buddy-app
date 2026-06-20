import 'package:equatable/equatable.dart';

class BookFormatEntity extends Equatable {
  final String type; // 'hardcover', 'ebook', 'audiobook'
  final String? isbn;
  final int? copies;
  final bool? available;
  final String? fileUrl;
  final String? fileName;
  final String? audioUrl;
  final String? audioFileName;
  final int? duration;

  const BookFormatEntity({
    required this.type,
    this.isbn,
    this.copies,
    this.available,
    this.fileUrl,
    this.fileName,
    this.audioUrl,
    this.audioFileName,
    this.duration,
  });

  @override
  List<Object?> get props => [
        type,
        isbn,
        copies,
        available,
        fileUrl,
        fileName,
        audioUrl,
        audioFileName,
        duration,
      ];
}

class BookVariantEntity extends Equatable {
  final String id;
  final String bookId;
  final String language; // 'english', 'hindi', 'marathi', 'tamil', 'malayalam'
  final List<BookFormatEntity> formats;
  final String? isbn;
  final String? donatorInfo;

  const BookVariantEntity({
    required this.id,
    required this.bookId,
    required this.language,
    required this.formats,
    this.isbn,
    this.donatorInfo,
  });

  @override
  List<Object?> get props => [id, bookId, language, formats, isbn, donatorInfo];
}

