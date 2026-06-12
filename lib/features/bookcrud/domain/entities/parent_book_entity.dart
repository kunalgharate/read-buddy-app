import 'dart:io';
import 'package:equatable/equatable.dart';

class ParentBookEntity extends Equatable {
  final String id;
  final String title;
  final String author;
  final String publisher;
  final String description;
  final String coverImageUrl;
  final File? coversingleImage;
  final List<String> categories;
  final List<String> tags;
  final String status; // 'Draft' or 'Published'

  const ParentBookEntity({
    required this.id,
    required this.title,
    required this.author,
    required this.publisher,
    required this.description,
    required this.coverImageUrl,
    this.coversingleImage,
    required this.categories,
    required this.tags,
    required this.status,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        author,
        publisher,
        description,
        coverImageUrl,
        coversingleImage,
        categories,
        tags,
        status,
      ];
}
