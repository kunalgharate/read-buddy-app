import 'package:dio/dio.dart';
import 'package:read_buddy_app/core/network/api_constants.dart';
import '../models/wishlist_book_model.dart';

abstract class WishlistRemoteDataSource {
  Future<List<WishlistBookModel>> getWishlist();
  Future<void> addToWishlist(String bookId);
  Future<void> removeFromWishlist(String bookId);
}

class WishlistRemoteDataSourceImpl implements WishlistRemoteDataSource {
  final Dio _dio;

  WishlistRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<WishlistBookModel>> getWishlist() async {
    final response = await _dio.get(ApiConstants.wishlist);
    final data = response.data;

    final List list;
    if (data is List) {
      list = data;
    } else if (data is Map && data.containsKey('data')) {
      list = data['data'] as List;
    } else if (data is Map && data.containsKey('wishlist')) {
      list = data['wishlist'] as List;
    } else {
      list = [];
    }

    return list
        .map((json) => WishlistBookModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> addToWishlist(String bookId) async {
    await _dio.post('${ApiConstants.wishlist}/add/$bookId');
  }

  @override
  Future<void> removeFromWishlist(String bookId) async {
    await _dio.delete('${ApiConstants.wishlist}/remove/$bookId');
  }
}
