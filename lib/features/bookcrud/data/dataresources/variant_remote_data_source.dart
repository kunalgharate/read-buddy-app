import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:read_buddy_app/core/di/injection.dart';
import 'package:read_buddy_app/core/utils/secure_storage_utils.dart';
import 'package:read_buddy_app/features/bookcrud/data/model/book_variant_model.dart';
import '../../../../core/network/api_constants.dart';

abstract class VariantRemoteDataSource {
  Future<List<BookVariantModel>> getVariantsForBook(String bookId);
  Future<BookVariantModel> createVariant(BookVariantModel variant);
  Future<BookVariantModel> updateVariant(String variantId, BookVariantModel variant);
  Future<void> deleteVariant(String variantId);
}

@Injectable(as: VariantRemoteDataSource)
class VariantRemoteDataSourceImpl implements VariantRemoteDataSource {
  final Dio dio;

  VariantRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<BookVariantModel>> getVariantsForBook(String bookId) async {
    try {
      final response = await dio.get('${ApiConstants.bookVariants}/$bookId');
      if (response.statusCode != 200) {
        throw Exception('Failed to load variants. Status code: ${response.statusCode}');
      }
      return (response.data as List).map((json) => BookVariantModel.fromJson(json)).toList();
    } catch (e) {
      print("❌ Error fetching book variants: $e");
      rethrow;
    }
  }

  @override
  Future<BookVariantModel> createVariant(BookVariantModel variant) async {
    try {
      final token = await getIt<SecureStorageUtil>().getAccessToken();
      final response = await dio.post(
        ApiConstants.bookVariants,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
        data: variant.toJson(),
      );
      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Failed to create variant. Status code: ${response.statusCode}');
      }
      return BookVariantModel.fromJson(response.data);
    } catch (e) {
      print("❌ Error creating book variant: $e");
      rethrow;
    }
  }

  @override
  Future<BookVariantModel> updateVariant(String variantId, BookVariantModel variant) async {
    try {
      final token = await getIt<SecureStorageUtil>().getAccessToken();
      final response = await dio.put(
        '${ApiConstants.bookVariants}/$variantId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
        data: variant.toJson(),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update variant. Status code: ${response.statusCode}');
      }
      return BookVariantModel.fromJson(response.data);
    } catch (e) {
      print("❌ Error updating book variant: $e");
      rethrow;
    }
  }

  @override
  Future<void> deleteVariant(String variantId) async {
    try {
      final token = await getIt<SecureStorageUtil>().getAccessToken();
      final response = await dio.delete(
        '${ApiConstants.bookVariants}/$variantId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to delete variant. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Error deleting book variant: $e");
      rethrow;
    }
  }
}
