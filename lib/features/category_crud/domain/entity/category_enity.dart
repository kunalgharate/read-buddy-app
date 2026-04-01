class CategoryEntity {
  final String id;
  final String title;
  final String parentCategory;
  final String parentCategoryId;
  final String imageUrl;

  const CategoryEntity({
    required this.id,
    required this.title,
    required this.parentCategory,
    this.parentCategoryId = '',
    required this.imageUrl,
  });

  @override
  List<Object?> get props =>
      [id, title, parentCategory, parentCategoryId, imageUrl];
}
