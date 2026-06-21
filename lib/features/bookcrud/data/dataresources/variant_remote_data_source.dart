import 'package:dio/dio.dart';
import 'package:read_buddy_app/core/di/injection.dart';
import 'package:read_buddy_app/core/utils/secure_storage_utils.dart';
import 'package:read_buddy_app/features/bookcrud/data/model/book_variant_model.dart';
import '../../../../core/network/api_constants.dart';

abstract class VariantRemoteDataSource {
  /// GET /api/book-variants/book/:bookId
  Future<List<BookVariantModel>> getVariantsForBook(String bookId);

  /// GET /api/book-variants/:variantId
  Future<BookVariantModel> getVariantById(String variantId);

  /// POST /api/book-variants
  Future<BookVariantModel> createVariant(BookVariantModel variant);

  /// PUT /api/book-variants/:variantId
  Future<BookVariantModel> updateVariant(
      String variantId, Map<String, dynamic> data);

  /// DELETE /api/book-variants/:variantId
  Future<void> deleteVariant(String variantId);

  /// POST /api/book-variants/:variantId/formats
  Future<BookVariantModel> addFormatsToVariant(
      String variantId, List<BookFormatModel> formats);

  /// DELETE /api/book-variants/:variantId/formats/:formatId
  Future<void> removeFormatFromVariant(String variantId, String formatId);
}

class VariantRemoteDataSourceImpl implements VariantRemoteDataSource {
  final Dio dio;

  VariantRemoteDataSourceImpl({required this.dio});

  Future<Options> _authOptions() async {
    final token = await getIt<SecureStorageUtil>().getAccessToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  @override
  Future<List<BookVariantModel>> getVariantsForBook(String bookId) async {
    final response = await dio.get('${ApiConstants.bookVariants}/book/$bookId');
    if (response.statusCode != 200) {
      throw Exception(
          'Failed to load variants. Status: ${response.statusCode}');
    }
    final data = response.data;
    if (data is List) {
      return data.map((json) => BookVariantModel.fromJson(json)).toList();
    }
    return [];
  }

  @override
  Future<BookVariantModel> getVariantById(String variantId) async {
    final response = await dio.get('${ApiConstants.bookVariants}/$variantId');
    if (response.statusCode != 200) {
      throw Exception('Failed to load variant. Status: ${response.statusCode}');
    }
    return BookVariantModel.fromJson(response.data);
  }

  @override
  Future<BookVariantModel> createVariant(BookVariantModel variant) async {
    final response = await dio.post(
      ApiConstants.bookVariants,
      options: await _authOptions(),
      data: variant.toJson(),
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(
          'Failed to create variant. Status: ${response.statusCode}');
    }
    return BookVariantModel.fromJson(response.data);
  }

  @override
  Future<BookVariantModel> updateVariant(
      String variantId, Map<String, dynamic> data) async {
    final response = await dio.put(
      '${ApiConstants.bookVariants}/$variantId',
      options: await _authOptions(),
      data: data,
    );
    if (response.statusCode != 200) {
      throw Exception(
          'Failed to update variant. Status: ${response.statusCode}');
    }
    return BookVariantModel.fromJson(response.data);
  }

  @override
  Future<void> deleteVariant(String variantId) async {
    final response = await dio.delete(
      '${ApiConstants.bookVariants}/$variantId',
      options: await _authOptions(),
    );
    if (response.statusCode != 200) {
      throw Exception(
          'Failed to delete variant. Status: ${response.statusCode}');
    }
  }

  @override
  Future<BookVariantModel> addFormatsToVariant(
      String variantId, List<BookFormatModel> formats) async {
    final response = await dio.post(
      '${ApiConstants.bookVariants}/$variantId/formats',
      options: await _authOptions(),
      data: {
        'formats': formats.map((f) => f.toJson()).toList(),
      },
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add formats. Status: ${response.statusCode}');
    }
    return BookVariantModel.fromJson(response.data);
  }

  @override
  Future<void> removeFormatFromVariant(
      String variantId, String formatId) async {
    final response = await dio.delete(
      '${ApiConstants.bookVariants}/$variantId/formats/$formatId',
      options: await _authOptions(),
    );
    if (response.statusCode != 200) {
      throw Exception(
          'Failed to remove format. Status: ${response.statusCode}');
    }
  }
}
