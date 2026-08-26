import 'package:equatable/equatable.dart';

class WishlistBookEntity extends Equatable {
  final String id;
  final String title;
  final String author;
  final String coverImageUrl;
  final double price;
  final String condition;
  final int pages;

  const WishlistBookEntity({
    required this.id,
    required this.title,
    required this.author,
    required this.coverImageUrl,
    required this.price,
    required this.condition,
    required this.pages,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        author,
        coverImageUrl,
        price,
        condition,
        pages,
      ];
}
