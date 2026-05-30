import '../../domain/entities/book_detail_entity.dart';

class BookDetailModel extends BookDetailEntity {
  const BookDetailModel({
    required super.id,
    required super.title,
    required super.author,
    required super.publisher,
    required super.publicationYear,
    required super.isbn,
    required super.condition,
    required super.isAvailable,
    required super.status,
    required super.numberOfCopies,
    required super.format,
    required super.language,
    required super.tags,
    required super.coverImageUrl,
    required super.additionalImages,
    required super.description,
    required super.owner,
    required super.address,
  });

  factory BookDetailModel.fromJson(Map<String, dynamic> json) {
    return BookDetailModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      publisher: json['publisher'] ?? '',
      publicationYear: json['publication_year'] ?? 0,
      isbn: json['isbn'] ?? '',
      condition: json['condition'] ?? '',
      isAvailable: json['is_available'] ?? false,
      status: json['status'] ?? '',
      numberOfCopies: json['number_of_copies'] ?? 0,
      format: json['format'] ?? '',
      language: json['language'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      coverImageUrl: json['coverImageUrl'] ?? '',
      additionalImages: List<String>.from(json['additional_images'] ?? []),
      description: json['description'] ?? '',
      owner: BookOwnerModel.fromJson(json['ownerId'] ?? {}),
      address: BookAddressModel.fromJson(json['address'] ?? {}),
    );
  }
}

class BookOwnerModel extends BookOwnerEntity {
  const BookOwnerModel({
    required super.id,
    required super.name,
    required super.email,
    super.picture,
  });

  factory BookOwnerModel.fromJson(Map<String, dynamic> json) {
    return BookOwnerModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      picture: json['picture'],
    );
  }
}

class BookAddressModel extends BookAddressEntity {
  const BookAddressModel({
    required super.city,
    required super.state,
    required super.country,
    required super.pincode,
  });

  factory BookAddressModel.fromJson(Map<String, dynamic> json) {
    return BookAddressModel(
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      pincode: json['pincode'] ?? '',
    );
  }
}
