import '../entities/wishlist_book_entity.dart';

abstract class WishlistRepository {
  Future<List<WishlistBookEntity>> getWishlist();
  Future<void> addToWishlist(String bookId);
  Future<void> removeFromWishlist(String bookId);
}
