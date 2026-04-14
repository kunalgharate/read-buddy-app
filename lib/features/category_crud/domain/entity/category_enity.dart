import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String title;
  final String? parentCategoryName;
  final String imageUrl;
  final String? description;

  const CategoryEntity({
    required this.id,
    required this.title,
    this.parentCategoryName,
    required this.imageUrl,
    this.description,
  });

  @override
  List<Object?> get props => [id, title, parentCategoryName, imageUrl, description];
}
