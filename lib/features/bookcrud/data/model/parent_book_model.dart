import 'dart:io';
import '../../domain/entities/parent_book_entity.dart';

class ParentBookModel extends ParentBookEntity {
  const ParentBookModel({
    required super.id,
    required super.title,
    required super.author,
    required super.publisher,
    required super.description,
    required super.coverImageUrl,
    super.coversingleImage,
    required super.categories,
    required super.tags,
    required super.status,
  });

  factory ParentBookModel.fromJson(Map<String, dynamic> json) {
    return ParentBookModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      publisher: json['publisher'] ?? '',
      description: json['description'] ?? '',
      coverImageUrl: json['coverImageUrl'] ?? '',
      categories: List<String>.from(json['categories'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      status: json['status'] ?? 'Published',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'author': author,
      'publisher': publisher,
      'description': description,
      'coverImageUrl': coverImageUrl,
      'categories': categories,
      'tags': tags,
      'status': status,
    };
  }

  factory ParentBookModel.fromEntity(ParentBookEntity entity) {
    return ParentBookModel(
      id: entity.id,
      title: entity.title,
      author: entity.author,
      publisher: entity.publisher,
      description: entity.description,
      coverImageUrl: entity.coverImageUrl,
      coversingleImage: entity.coversingleImage,
      categories: entity.categories,
      tags: entity.tags,
      status: entity.status,
    );
  }
}
