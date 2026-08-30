import '../../domain/entities/wishlist_book_entity.dart';
import '../../domain/repositories/wishlist_repository.dart';
import '../datasources/wishlist_remote_datasource.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  final WishlistRemoteDataSource _remoteDataSource;

  WishlistRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<WishlistBookEntity>> getWishlist() =>
      _remoteDataSource.getWishlist();

  @override
  Future<void> addToWishlist(String bookId) =>
      _remoteDataSource.addToWishlist(bookId);

  @override
  Future<void> removeFromWishlist(String bookId) =>
      _remoteDataSource.removeFromWishlist(bookId);
}
