class BookEntity {
  final String id;
  final String title;
  final String? subtitle;
  final String author;
  final String? publisher;
  final int? publicationYear;
  final String? isbn;
  final String? edition;
  final String condition;
  final bool isAvailable;
  final String status;
  final int numberOfCopies;
  final String format;
  final String language;
  final String? genre;
  final List<String> tags;
  final String? coverImageUrl;
  final List<String> additionalImages;
  final String? description;
  final String ownerId;
  final BookAddressEntity? address;
  final DateTime? createdAt;

  const BookEntity({
    required this.id,
    required this.title,
    this.subtitle,
    required this.author,
    this.publisher,
    this.publicationYear,
    this.isbn,
    this.edition,
    required this.condition,
    required this.isAvailable,
    required this.status,
    required this.numberOfCopies,
    required this.format,
    required this.language,
    this.genre,
    required this.tags,
    this.coverImageUrl,
    required this.additionalImages,
    this.description,
    required this.ownerId,
    this.address,
    required this.createdAt,
  });
}

class BookAddressEntity {
  final String? city;
  final String? state;
  final String? country;
  final String? pincode;
  final double? latitude;
  final double? longitude;

  const BookAddressEntity({
    this.city,
    this.state,
    this.country,
    this.pincode,
    this.latitude,
    this.longitude,
  });
}
