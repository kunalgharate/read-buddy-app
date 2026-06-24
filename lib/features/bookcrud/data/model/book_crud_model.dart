import 'dart:io';

import 'package:read_buddy_app/features/bookcrud/data/model/book_variant_model.dart';
import 'package:read_buddy_app/features/bookcrud/domain/entities/book_crud.dart';
import 'package:read_buddy_app/features/bookcrud/domain/entities/book_variant_entity.dart';

class BookCrudModel extends BookCrudEntity {
  @override
  final List<String> additionalImageUrls;
  @override
  final File? coversingleImage;

  /// Variants returned inline from GET /api/books response.
  final List<BookVariantEntity> variants;

  BookCrudModel({
    required super.title,
    String? subtitle,
    required super.author,
    required super.publisher,
    required super.publicationYear,
    required super.isbn,
    required super.edition,
    required super.condition,
    required super.isAvailable,
    required super.status,
    required super.numberOfCopies,
    required super.format,
    required super.language,
    required super.genre,
    required super.tags,
    required super.category,
    super.categoryId,
    String? id,
    required super.ownerId,
    super.ownerName,
    required super.location,
    this.coversingleImage,
    required super.coverImageUrl,
    required super.additionalImages,
    List<String>? additionalImageUrls,
    required super.description,
    required super.notes,
    this.variants = const [],
  })  : additionalImageUrls = additionalImageUrls ?? [],
        super(
          subtitle: subtitle ?? "subtitle",
          id: id ?? "id-",
          coversingleImage: coversingleImage,
        );

  factory BookCrudModel.fromJson(Map<String, dynamic> json) {
    // Handle categories — API returns multiple formats:
    // 1. New books: "categories": [{ _id, name, imageUrl, description }] — populated
    // 2. Old books: "category": "687671aeea6072ce4a153bf7" — plain string ID
    // 3. Old books: "category": ["id1", "id2"] — array of string IDs
    String categoryName = "";
    String? categoryId;

    final categoriesData = json['categories'];
    final categoryData = json['category'];

    if (categoriesData is List && categoriesData.isNotEmpty) {
      final first = categoriesData.first;
      if (first is Map<String, dynamic>) {
        // Populated object — extract name directly
        categoryName = first['name'] ?? "";
        categoryId = first['_id'];
      } else if (first is String) {
        // Array of string IDs
        categoryId = first;
      }
    } else if (categoryData is List && categoryData.isNotEmpty) {
      // "category": ["id1", "id2"] — old format with array of IDs
      final first = categoryData.first;
      if (first is Map<String, dynamic>) {
        categoryName = first['name'] ?? "";
        categoryId = first['_id'];
      } else if (first is String) {
        categoryId = first;
      }
    } else if (categoryData is Map<String, dynamic>) {
      categoryName = categoryData['name'] ?? "";
      categoryId = categoryData['_id'];
    } else if (categoryData is String && categoryData.isNotEmpty) {
      categoryId = categoryData;
    }

    final ownerData = json['ownerId'];
    String ownerId = "";
    String? ownerName;
    if (ownerData is Map<String, dynamic>) {
      ownerId = ownerData['_id'] ?? "";
      ownerName = ownerData['name'];
    } else if (ownerData is String) {
      ownerId = ownerData;
    }

    return BookCrudModel(
      title: json['title'] ?? "title",
      subtitle: json['subtitle'] ?? "subtitle",
      author: json['author'] ?? "-author-",
      publisher: json['publisher'] ?? "_pub-",
      publicationYear: json['publication_year'] ?? 0,
      isbn: json['isbn'] ?? "isbn",
      edition: json['edition'] ?? "edition",
      condition: json['condition'] ?? "-condition",
      isAvailable: json['is_available'] ?? false,
      status: json['status'] ?? "stat",
      numberOfCopies: json['number_of_copies'] ?? 0,
      format: json['format'] ?? "format",
      language: json['language'] ?? "language",
      genre: json['genre'] ?? "genre",
      tags: List<String>.from(json['tags'] ?? []),
      category: categoryName,
      categoryId: categoryId,
      id: json['_id'],
      ownerId: ownerId,
      ownerName: ownerName,
      location: json['location'] ?? "location",
      coverImageUrl: json['coverImageUrl'] ?? "",
      additionalImageUrls: List<String>.from(json['additional_images'] ?? []),
      additionalImages: [], // Cannot get File from API
      description: json['description'] ?? "",
      notes: json['notes'] ?? "",
      coversingleImage: null,
      variants: (json['variants'] as List?)
              ?.map((v) => BookVariantModel.fromJson(v))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'author': author,
      'publisher': publisher,
      'publication_year': publicationYear,
      'isbn': isbn,
      'edition': edition,
      'condition': condition,
      'is_available': isAvailable,
      'status': status,
      'number_of_copies': numberOfCopies,
      'format': format,
      'language': language,
      'genre': genre,
      'tags': tags,
      'category': category,
      'categoryId': categoryId,
      'ownerId': ownerId,
      'location': location,
      'coverImageUrl': coverImageUrl,
      'additional_images': additionalImageUrls,
      'description': description,
      'notes': notes,
      // 'coversingleImage': Not added because File can't be serialized to JSON directly
    };
  }

  factory BookCrudModel.fromEntity(BookCrudEntity book) {
    return BookCrudModel(
      id: book.id,
      title: book.title,
      subtitle: book.subtitle,
      author: book.author,
      publisher: book.publisher,
      publicationYear: book.publicationYear,
      isbn: book.isbn,
      edition: book.edition,
      condition: book.condition,
      isAvailable: book.isAvailable,
      status: book.status,
      numberOfCopies: book.numberOfCopies,
      format: book.format,
      language: book.language,
      genre: book.genre,
      tags: book.tags,
      category: book.category,
      categoryId: book.categoryId,
      ownerId: book.ownerId,
      ownerName: book.ownerName,
      location: book.location,
      coverImageUrl: book.coverImageUrl,
      additionalImages: book.additionalImages,
      description: book.description,
      notes: book.notes,
      coversingleImage: book.coversingleImage,
      variants: book is BookCrudModel ? book.variants : const [],
    );
  }

  BookCrudEntity toEntity() => BookCrudEntity(
        id: id,
        title: title,
        subtitle: subtitle,
        author: author,
        publisher: publisher,
        publicationYear: publicationYear,
        isbn: isbn,
        edition: edition,
        condition: condition,
        isAvailable: isAvailable,
        status: status,
        numberOfCopies: numberOfCopies,
        format: format,
        language: language,
        genre: genre,
        tags: tags,
        category: category,
        categoryId: categoryId,
        ownerId: ownerId,
        ownerName: ownerName,
        location: location,
        coverImageUrl: coverImageUrl,
        additionalImages: additionalImages,
        description: description,
        notes: notes,
        coversingleImage: coversingleImage,
      );

  BookCrudModel copyWith({
    String? condition,
    String? ownerId,
    String? location,
    String? description,
    String? coverImageUrl,
    File? coversingleImage,
    List<File>? additionalImages,
    List<String>? additionalImageUrls,
    List<String>? tags,
    String? notes,
  }) {
    return BookCrudModel(
      id: id,
      title: title,
      subtitle: subtitle,
      author: author,
      publisher: publisher,
      publicationYear: publicationYear,
      isbn: isbn,
      edition: edition,
      condition: condition ?? this.condition,
      isAvailable: isAvailable,
      status: status,
      numberOfCopies: numberOfCopies,
      format: format,
      language: language,
      genre: genre,
      tags: tags ?? this.tags,
      category: category,
      categoryId: categoryId,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName,
      location: location ?? this.location,
      coversingleImage: coversingleImage ?? this.coversingleImage,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      additionalImages: additionalImages ?? this.additionalImages,
      additionalImageUrls: additionalImageUrls ?? this.additionalImageUrls,
      description: description ?? this.description,
      notes: notes ?? this.notes,
    );
  }
}
