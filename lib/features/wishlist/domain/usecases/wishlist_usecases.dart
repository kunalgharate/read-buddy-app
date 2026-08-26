import '../entities/wishlist_book_entity.dart';
import '../repositories/wishlist_repository.dart';

class GetWishlist {
  final WishlistRepository _repository;
  GetWishlist(this._repository);

  Future<List<WishlistBookEntity>> call() => _repository.getWishlist();
}

class AddToWishlist {
  final WishlistRepository _repository;
  AddToWishlist(this._repository);

  Future<void> call(String bookId) => _repository.addToWishlist(bookId);
}

class RemoveFromWishlist {
  final WishlistRepository _repository;
  RemoveFromWishlist(this._repository);

  Future<void> call(String bookId) => _repository.removeFromWishlist(bookId);
}
