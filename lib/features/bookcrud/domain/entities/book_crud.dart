// // lib/features/book/domain/entities/book.dart

// import 'dart:io';

// import 'package:equatable/equatable.dart';

// class BookCrudEntity extends Equatable {
//   final String title;
//   final String subtitle;
//   final String author;
//   final String publisher;
//   final int publicationYear;
//   final String isbn;
//   final String edition;
//   final String condition;
//   final bool isAvailable;
//   final String status;
//   final int numberOfCopies;
//   final String format;
//   final String language;
//   final String genre;
//   final List<String> tags;
//   final String category;
//   final String? categoryId;
//   final String? id;
//   final String ownerId;
//   final String? ownerName;
//   final String location;
//   final String coverImageUrl;
//   final List<File> additionalImages;
//   final String description;
//   final String notes;

//   const BookCrudEntity({
//     required this.title,
//     required this.subtitle,
//     required this.author,
//     required this.publisher,
//     required this.publicationYear,
//     required this.isbn,
//     required this.edition,
//     required this.condition,
//     required this.isAvailable,
//     required this.status,
//     required this.numberOfCopies,
//     required this.format,
//     required this.language,
//     required this.genre,
//     required this.tags,
//     required this.category,
//     this.categoryId,
//     this.id,
//     required this.ownerId,
//     this.ownerName,
//     required this.location,
//     required this.coverImageUrl,
//     required this.additionalImages,
//     required this.description,
//     required this.notes,
//   });

//   @override
//   List<Object?> get props => [
//         title,
//         subtitle,
//         author,
//         publisher,
//         publicationYear,
//         isbn,
//         edition,
//         condition,
//         isAvailable,
//         status,
//         numberOfCopies,
//         format,
//         language,
//         genre,
//         tags,
//         category,
//         categoryId,
//         id,
//         ownerId,
//         location,
//         coverImageUrl,
//         additionalImages,
//         description,
//         notes
//       ];
// }

import 'dart:io';

import 'package:equatable/equatable.dart';

class BookCrudEntity extends Equatable {
  final String title;
  final String subtitle;
  final String author;
  final String publisher;
  final int publicationYear;
  final String isbn;
  final String edition;
  final String condition;
  final bool isAvailable;
  final String status;
  final int numberOfCopies;
  final String format;
  final String language;
  final String genre;
  final List<String> tags;
  final String category;
  final String? categoryId;
  final String? id;
  final String ownerId;
  final String? ownerName;
  final String location;
  final String coverImageUrl;
  final List<File> additionalImages;
  final String description;
  final String notes;
  final List<String>? additionalImageUrls;
  final File? coversingleImage; // 👈 Newly added field

  const BookCrudEntity({
    required this.title,
    required this.subtitle,
    required this.author,
    required this.publisher,
    required this.publicationYear,
    required this.isbn,
    required this.edition,
    required this.condition,
    required this.isAvailable,
    required this.status,
    required this.numberOfCopies,
    required this.format,
    required this.language,
    required this.genre,
    required this.tags,
    required this.category,
    this.categoryId,
    this.id,
    required this.ownerId,
    this.ownerName,
    required this.location,
    required this.coverImageUrl,
    required this.additionalImages,
    required this.description,
    required this.notes,
    this.additionalImageUrls,
    this.coversingleImage, // 👈 Constructor update
  });

  @override
  List<Object?> get props => [
        title,
        subtitle,
        author,
        publisher,
        publicationYear,
        isbn,
        edition,
        condition,
        isAvailable,
        status,
        numberOfCopies,
        format,
        language,
        genre,
        tags,
        category,
        categoryId,
        id,
        ownerId,
        ownerName,
        location,
        coverImageUrl,
        additionalImages,
        description,
        notes,
        coversingleImage, // 👈 props update
      ];
}
