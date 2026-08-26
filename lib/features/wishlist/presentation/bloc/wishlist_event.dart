part of 'wishlist_bloc.dart';

sealed class WishlistEvent extends Equatable {
  const WishlistEvent();
  @override
  List<Object?> get props => [];
}

final class LoadWishlist extends WishlistEvent {}

final class AddBookToWishlist extends WishlistEvent {
  final String bookId;
  const AddBookToWishlist(this.bookId);
  @override
  List<Object?> get props => [bookId];
}

final class RemoveBookFromWishlist extends WishlistEvent {
  final String bookId;
  const RemoveBookFromWishlist(this.bookId);
  @override
  List<Object?> get props => [bookId];
}
