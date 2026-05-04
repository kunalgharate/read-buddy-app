import 'package:equatable/equatable.dart';

class BookDetailEntity extends Equatable {
  final String id;
  final String title;
  final String author;
  final String publisher;
  final int publicationYear;
  final String isbn;
  final String condition;
  final bool isAvailable;
  final String status;
  final int numberOfCopies;
  final String format;
  final String language;
  final List<String> tags;
  final String coverImageUrl;
  final List<String> additionalImages;
  final String description;
  final BookOwnerEntity owner;
  final BookAddressEntity address;

  const BookDetailEntity({
    required this.id,
    required this.title,
    required this.author,
    required this.publisher,
    required this.publicationYear,
    required this.isbn,
    required this.condition,
    required this.isAvailable,
    required this.status,
    required this.numberOfCopies,
    required this.format,
    required this.language,
    required this.tags,
    required this.coverImageUrl,
    required this.additionalImages,
    required this.description,
    required this.owner,
    required this.address,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        author,
        publisher,
        publicationYear,
        isbn,
        condition,
        isAvailable,
        status,
        numberOfCopies,
        format,
        language,
        tags,
        coverImageUrl,
        additionalImages,
        description,
        owner,
        address,
      ];
}

class BookOwnerEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? picture;

  const BookOwnerEntity({
    required this.id,
    required this.name,
    required this.email,
    this.picture,
  });

  @override
  List<Object?> get props => [id, name, email, picture];
}

class BookAddressEntity extends Equatable {
  final String city;
  final String state;
  final String country;
  final String pincode;

  const BookAddressEntity({
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
  });

  @override
  List<Object?> get props => [city, state, country, pincode];
}
