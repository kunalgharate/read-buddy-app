import '../../domain/entities/wishlist_book_entity.dart';

class WishlistBookModel extends WishlistBookEntity {
  const WishlistBookModel({
    required super.id,
    required super.title,
    required super.author,
    required super.coverImageUrl,
    required super.price,
    required super.condition,
    required super.pages,
  });

  factory WishlistBookModel.fromJson(Map<String, dynamic> json) {
    return WishlistBookModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      author: json['author']?.toString() ?? '',
      coverImageUrl: json['coverImageUrl']?.toString() ??
          json['coverImage']?.toString() ??
          '',
      price: (json['price'] ?? 0).toDouble(),
      condition: json['condition']?.toString() ?? 'Good',
      pages: json['pages'] is int
          ? json['pages'] as int
          : int.tryParse(json['pages']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'author': author,
        'coverImageUrl': coverImageUrl,
        'price': price,
        'condition': condition,
        'pages': pages,
      };
}
