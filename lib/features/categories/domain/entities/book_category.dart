import 'package:equatable/equatable.dart';

class BookCategory extends Equatable {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String? parentCategoryName;
  final int bookCount;

  const BookCategory({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.parentCategoryName,
    required this.bookCount,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        imageUrl,
        parentCategoryName,
        bookCount,
      ];
}
