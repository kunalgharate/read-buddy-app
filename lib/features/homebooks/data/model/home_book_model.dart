import '../../domain/entities/book_entity.dart';

class BookModel extends BookEntity {
  const BookModel({
    required super.id,
    required super.title,
    super.subtitle,
    required super.author,
    super.publisher,
    super.publicationYear,
    super.isbn,
    super.edition,
    required super.condition,
    required super.isAvailable,
    required super.status,
    required super.numberOfCopies,
    required super.format,
    required super.language,
    super.genre,
    required super.tags,
    super.coverImageUrl,
    required super.additionalImages,
    super.description,
    required super.ownerId,
    super.address,
    required super.createdAt,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'],
      author: json['author'] ?? '',
      publisher: json['publisher'],
      publicationYear: json['publication_year'],
      isbn: json['isbn'],
      edition: json['edition'],
      condition: json['condition'] ?? '',
      isAvailable: json['is_available'] ?? false,
      status: json['status'] ?? '',
      numberOfCopies: json['number_of_copies'] ?? 0,
      format: json['format'] ?? '',
      language: json['language'] ?? '',
      genre: json['genre'],
      tags: _parseTags(json['tags']),
      coverImageUrl: json['coverImageUrl'],
      additionalImages: List<String>.from(json['additional_images'] ?? []),
      description: json['description'],
      ownerId: json['ownerId'] ?? '',
      address: json['address'] != null
          ? BookAddressModel.fromJson(json['address'])
          : null,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  // tags field inconsistent hai API mein — ["romance,fiction,love"] style bhi hai
  static List<String> _parseTags(dynamic tags) {
    if (tags == null) return [];
    return (tags as List)
        .expand((tag) => tag.toString().split(','))
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
  }
}

class BookAddressModel extends BookAddressEntity {
  const BookAddressModel({
    super.city,
    super.state,
    super.country,
    super.pincode,
    super.latitude,
    super.longitude,
  });

  factory BookAddressModel.fromJson(Map<String, dynamic> json) {
    return BookAddressModel(
      city: json['city'],
      state: json['state'],
      country: json['country'],
      pincode: json['pincode'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }
}
