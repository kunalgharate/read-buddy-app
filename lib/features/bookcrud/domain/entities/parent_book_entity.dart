import 'dart:io';
import 'package:equatable/equatable.dart';

/// Core book metadata — the "parent" book entity.
/// BookVariants attach to this via bookId.
class ParentBookEntity extends Equatable {
  final String id;
  final String title;
  final String author;
  final String publisher;
  final String description;
  final String coverImageUrl;
  final File? coverImage;
  final List<String> categories; // category ObjectIds
  final List<String> tags;

  const ParentBookEntity({
    required this.id,
    required this.title,
    required this.author,
    required this.publisher,
    required this.description,
    required this.coverImageUrl,
    this.coverImage,
    required this.categories,
    required this.tags,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        author,
        publisher,
        description,
        coverImageUrl,
        coverImage,
        categories,
        tags,
      ];
}
