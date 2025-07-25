import 'package:equatable/equatable.dart';
import 'package:read_buddy_app/features/books/domain/entities/book.dart';

class WishlistState extends Equatable {
  final List<Book> books;
  final bool isMenuVisible;
  final bool isMenuPermanentlyClosed;

  const WishlistState({
    this.books = const [],
    this.isMenuVisible = false,
    this.isMenuPermanentlyClosed = false,
  });

  WishlistState copyWith({
    List<Book>? books,
    bool? isMenuVisible,
    bool? isMenuPermanentlyClosed,
  }) {
    return WishlistState(
      books: books ?? this.books,
      isMenuVisible: isMenuVisible ?? this.isMenuVisible,
      isMenuPermanentlyClosed:
          isMenuPermanentlyClosed ?? this.isMenuPermanentlyClosed,
    );
  }

  @override
  List<Object?> get props => [
        books,
        isMenuVisible,
        isMenuPermanentlyClosed,
      ];
}
