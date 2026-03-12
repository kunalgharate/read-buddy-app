class CategoryEntity {
  final String id;
  final String title;
  final String parentCategory;
  final String imageUrl;

  const CategoryEntity({
    required this.id,
    required this.title,
    required this.parentCategory,
    required this.imageUrl,
  });

  @override
  List<Object?> get props => [id, title, parentCategory, imageUrl];
}
