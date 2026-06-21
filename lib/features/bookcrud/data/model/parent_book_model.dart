import 'package:dio/dio.dart';
import '../../domain/entities/parent_book_entity.dart';

class ParentBookModel extends ParentBookEntity {
  const ParentBookModel({
    required super.id,
    required super.title,
    required super.author,
    required super.publisher,
    required super.description,
    required super.coverImageUrl,
    super.coverImage,
    required super.categories,
    required super.tags,
  });

  factory ParentBookModel.fromJson(Map<String, dynamic> json) {
    // categories can be list of strings or list of objects
    final rawCategories = json['categories'] ?? [];
    final categories = (rawCategories as List).map((c) {
      if (c is Map<String, dynamic>) return c['_id'] ?? '';
      return c.toString();
    }).toList();

    return ParentBookModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      publisher: json['publisher'] ?? '',
      description: json['description'] ?? '',
      coverImageUrl: json['coverImageUrl'] ?? json['coverImage'] ?? '',
      categories: categories.cast<String>(),
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  /// Creates FormData for POST /api/books (multipart).
  Future<FormData> toFormData() async {
    final map = <String, dynamic>{
      'title': title,
      'author': author,
    };
    if (publisher.isNotEmpty) map['publisher'] = publisher;
    if (description.isNotEmpty) map['description'] = description;
    if (categories.isNotEmpty) map['categories'] = categories.toString();
    if (tags.isNotEmpty) map['tags'] = tags.toString();
    if (coverImage != null) {
      map['coverImage'] = await MultipartFile.fromFile(
        coverImage!.path,
        filename: coverImage!.path.split('/').last,
      );
    }
    return FormData.fromMap(map);
  }

  /// For PUT /api/books/:id — sends only provided fields as formdata.
  Future<FormData> toUpdateFormData({
    String? title,
    String? author,
    String? publisher,
    String? description,
    List<String>? categories,
    List<String>? tags,
  }) async {
    final map = <String, dynamic>{};
    if (title != null) map['title'] = title;
    if (author != null) map['author'] = author;
    if (publisher != null) map['publisher'] = publisher;
    if (description != null) map['description'] = description;
    if (categories != null) map['categories'] = categories.toString();
    if (tags != null) map['tags'] = tags.toString();
    if (coverImage != null) {
      map['coverImage'] = await MultipartFile.fromFile(
        coverImage!.path,
        filename: coverImage!.path.split('/').last,
      );
    }
    return FormData.fromMap(map);
  }

  factory ParentBookModel.fromEntity(ParentBookEntity entity) {
    return ParentBookModel(
      id: entity.id,
      title: entity.title,
      author: entity.author,
      publisher: entity.publisher,
      description: entity.description,
      coverImageUrl: entity.coverImageUrl,
      coverImage: entity.coverImage,
      categories: entity.categories,
      tags: entity.tags,
    );
  }
}
