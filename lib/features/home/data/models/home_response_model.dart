// import 'package:read_buddy_app/features/home/domain/entities/book_entity.dart';

// class BookResponseModel {
//   final String id;
//   final String title;
//   final String? subtitle;
//   final String author;
//   final String publisher;
//   final int publicationYear;
//   final String? isbn;
//   final String? edition;
//   final String condition;
//   final bool isAvailable;
//   final String status;
//   final int numberOfCopies;
//   final String format;
//   final String? language;
//   final String? genre;
//   final List<String> tags;
//   final String? category;
//   final String ownerId;
//   final String? coverImageUrl;
//   final List<String> additionalImages;
//   final String description;
//   final Map<String, dynamic>? address;
//   final String? notes;
//   final String? location;
//   final DateTime? deletedAt;
//   final DateTime createdAt;
//   final DateTime updatedAt;

//   BookResponseModel({
//     required this.id,
//     required this.title,
//     this.subtitle,
//     required this.author,
//     required this.publisher,
//     required this.publicationYear,
//     this.isbn,
//     this.edition,
//     required this.condition,
//     required this.isAvailable,
//     required this.status,
//     required this.numberOfCopies,
//     required this.format,
//     this.language,
//     this.genre,
//     required this.tags,
//     this.category,
//     required this.ownerId,
//     this.coverImageUrl,
//     required this.additionalImages,
//     required this.description,
//     this.address,
//     this.notes,
//     this.location,
//     this.deletedAt,
//     required this.createdAt,
//     required this.updatedAt,
//   });

//   factory BookResponseModel.fromJson(Map<String, dynamic> json) {
//     return BookResponseModel(
//       id: json['_id'] ?? '',
//       title: json['title'] ?? '',
//       subtitle: json['subtitle'],
//       author: json['author'] ?? '',
//       publisher: json['publisher'] ?? '',
//       publicationYear: json['publication_year'] ?? 0,
//       isbn: json['isbn'],
//       edition: json['edition'],
//       condition: json['condition'] ?? '',
//       isAvailable: json['is_available'] ?? false,
//       status: json['status'] ?? '',
//       numberOfCopies: json['number_of_copies'] ?? 0,
//       format: json['format'] ?? '',
//       language: json['language'],
//       genre: json['genre'],
//       tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
//       category: json['category'],
//       ownerId: json['ownerId'] ?? '',
//       coverImageUrl: json['coverImageUrl'],
//       additionalImages: json['additional_images'] != null
//           ? List<String>.from(json['additional_images'])
//           : [],
//       description: json['description'] ?? '',
//       address: json['address'],
//       notes: json['notes'],
//       location: json['location'],
//       deletedAt: json['deleted_at'] != null
//           ? DateTime.parse(json['deleted_at'])
//           : null,
//       createdAt: DateTime.parse(json['createdAt']),
//       updatedAt: DateTime.parse(json['updatedAt']),
//     );
//   }

//   RecommendedBookCardEntity toRecommendedEntity() {
//     return RecommendedBookCardEntity(
//       title: title,
//       category: category ?? '',
//       donor: author,
//       format: format,
//       duration: '',
//       imageUrl: coverImageUrl ?? '',
//       formatUrl: '',
//     );
//   }

//   LatestBookEntity toLatestEntity() {
//     return LatestBookEntity(
//       title: title,
//       category: category ?? '',
//       donor: author,
//       format: format,
//       duration: '',
//       imageUrl: coverImageUrl ?? '',
//       formatUrl: '',
//     );
//   }
// }

// class StatModel {
//   final String bookDonated;
//   final String activeUsers;
//   final String deleveries;
//   StatModel({
//     required this.bookDonated,
//     required this.activeUsers,
//     required this.deleveries,
//   });
//   factory StatModel.fromJson(Map<String, dynamic> json) {
//     return StatModel(
//       bookDonated: json['book_donated'],
//       activeUsers: json['active_users'],
//       deleveries: json['deliveries'],
//     );
//   }
//   StatEntity toEntity() {
//     return StatEntity(
//       bookDonated: bookDonated,
//       activeUsers: activeUsers,
//       deleveries: deleveries,
//     );
//   }
// }

import 'package:read_buddy_app/features/home/domain/entities/book_entity.dart';

class BookResponseModel {
  final String id;
  final String title;
  final String category;
  final String donor;
  final String format;
  final String duration;
  final String imageUrl;
  final String formatUrl;

  BookResponseModel({
    required this.id,
    required this.title,
    required this.category,
    required this.donor,
    required this.format,
    required this.duration,
    required this.imageUrl,
    required this.formatUrl,
  });

  factory BookResponseModel.fromJson(Map<String, dynamic> json) {
    return BookResponseModel(
      id: json['_id'] ?? '',
      title: json['title'],
      category: json['category'] ?? 'General',
      donor: json['author'] ?? 'Unknown',
      format: json['format'] ?? 'Unknown',
      duration: '3 Days',
      imageUrl: json['coverImageUrl'] ?? 'assets/fiction.png',
      formatUrl: 'assets/fiction.png',
    );
  }

  RecommendedBookCardEntity toRecommendedEntity() {
    return RecommendedBookCardEntity(
      title: title,
      category: category,
      donor: donor,
      format: format,
      duration: duration,
      imageUrl: imageUrl,
      formatUrl: formatUrl,
    );
  }

  LatestBookEntity toLatestEntity() {
    return LatestBookEntity(
      title: title,
      category: category,
      donor: donor,
      format: format,
      duration: duration,
      imageUrl: imageUrl,
      formatUrl: formatUrl,
    );
  }
}

class StatModel {
  final String bookDonated;
  final String activeUsers;
  final String deleveries;
  StatModel({
    required this.bookDonated,
    required this.activeUsers,
    required this.deleveries,
  });
  factory StatModel.fromJson(Map<String, dynamic> json) {
    return StatModel(
      bookDonated: json['book_donated'],
      activeUsers: json['active_users'],
      deleveries: json['deliveries'],
    );
  }
  StatEntity toEntity() {
    return StatEntity(
      bookDonated: bookDonated,
      activeUsers: activeUsers,
      deleveries: deleveries,
    );
  }
}
