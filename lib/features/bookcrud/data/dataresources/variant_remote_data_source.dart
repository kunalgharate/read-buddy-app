import 'dart:convert';
import 'dart:io';

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

  /// POST /api/book-variants (multipart form data with files)
  Future<BookVariantModel> createVariant(
    BookVariantModel variant, {
    List<File> ebookFiles,
    List<File> audioParts,
    List<File> videoParts,
  });

  /// PUT /api/book-variants/:variantId
  Future<BookVariantModel> updateVariant(
      String variantId, Map<String, dynamic> data);

  /// DELETE /api/book-variants/:variantId
  Future<void> deleteVariant(String variantId);

  /// POST /api/book-variants/:variantId/formats (multipart with files)
  Future<BookVariantModel> addFormatsToVariant(
    String variantId,
    List<BookFormatModel> formats, {
    List<File> ebookFiles,
    List<File> audioParts,
    List<File> videoParts,
  });

  /// DELETE /api/book-variants/:variantId/formats/:formatId
  Future<void> removeFormatFromVariant(String variantId, String formatId);
}

class VariantRemoteDataSourceImpl implements VariantRemoteDataSource {
  final Dio dio;

  VariantRemoteDataSourceImpl({required this.dio});

  Future<Options> _authOptions({String? contentType}) async {
    final token = await getIt<SecureStorageUtil>().getAccessToken();
    return Options(headers: {
      'Authorization': 'Bearer $token',
      if (contentType != null) 'Content-Type': contentType,
    });
  }

  @override
  Future<List<BookVariantModel>> getVariantsForBook(String bookId) async {
    final response = await dio.get('${ApiConstants.bookVariants}/book/$bookId');
    if (response.statusCode != 200) {
      throw Exception(
          'Failed to load variants. Status: ${response.statusCode}');
    }
    // Unwrap { "data": [...] } envelope if present
    final rawData = response.data;
    dynamic data;
    if (rawData is Map<String, dynamic> && rawData.containsKey('data')) {
      data = rawData['data'];
    } else {
      data = rawData;
    }
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
    // Unwrap { "data": {...} } envelope if present
    final rawData = response.data;
    final json =
        (rawData is Map<String, dynamic> && rawData.containsKey('data'))
            ? rawData['data']
            : rawData;
    return BookVariantModel.fromJson(json);
  }

  @override
  Future<BookVariantModel> createVariant(
    BookVariantModel variant, {
    List<File> ebookFiles = const [],
    List<File> audioParts = const [],
    List<File> videoParts = const [],
  }) async {
    final formatsList = variant.formats
        .map((item) => BookFormatModel.fromEntity(item).toJson())
        .toList();

    final bool hasFiles =
        ebookFiles.isNotEmpty || audioParts.isNotEmpty || videoParts.isNotEmpty;

    Response response;

    if (!hasFiles) {
      // No files — send as JSON body (express-validator can validate arrays directly)
      final jsonBody = {
        'bookId': variant.bookId,
        'language': variant.language,
        if (variant.donorId != null) 'donorId': variant.donorId,
        'formats': formatsList,
      };

      response = await dio.post(
        ApiConstants.bookVariants,
        options: await _authOptions(),
        data: jsonBody,
      );
    } else {
      // Has files — use multipart form data
      final formData = FormData();
      formData.fields.add(MapEntry('bookId', variant.bookId));
      formData.fields.add(MapEntry('language', variant.language));
      if (variant.donorId != null) {
        formData.fields.add(MapEntry('donorId', variant.donorId!));
      }
      formData.fields.add(MapEntry('formats', jsonEncode(formatsList)));

      for (final file in ebookFiles) {
        final bytes = await file.readAsBytes();
        formData.files.add(MapEntry(
          'ebookFiles',
          MultipartFile.fromBytes(bytes, filename: file.path.split('/').last),
        ));
      }
      for (final file in audioParts) {
        final bytes = await file.readAsBytes();
        formData.files.add(MapEntry(
          'audioParts',
          MultipartFile.fromBytes(bytes, filename: file.path.split('/').last),
        ));
      }
      for (final file in videoParts) {
        final bytes = await file.readAsBytes();
        formData.files.add(MapEntry(
          'videoParts',
          MultipartFile.fromBytes(bytes, filename: file.path.split('/').last),
        ));
      }

      response = await dio.post(
        ApiConstants.bookVariants,
        options: await _authOptions(contentType: 'multipart/form-data'),
        data: formData,
      );
    }

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(
          'Failed to create variant. Status: ${response.statusCode}');
    }
    final rawData = response.data;
    final json =
        (rawData is Map<String, dynamic> && rawData.containsKey('data'))
            ? rawData['data']
            : rawData;
    return BookVariantModel.fromJson(json);
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
    final rawData = response.data;
    final json =
        (rawData is Map<String, dynamic> && rawData.containsKey('data'))
            ? rawData['data']
            : rawData;
    return BookVariantModel.fromJson(json);
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
    String variantId,
    List<BookFormatModel> formats, {
    List<File> ebookFiles = const [],
    List<File> audioParts = const [],
    List<File> videoParts = const [],
  }) async {
    final formatsJson = jsonEncode(
      formats.map((f) => f.toJson()).toList(),
    );

    final formData = FormData();
    formData.fields.add(MapEntry('formats', formatsJson));

    // Attach ebook files
    for (final file in ebookFiles) {
      final bytes = await file.readAsBytes();
      formData.files.add(MapEntry(
        'ebookFiles',
        MultipartFile.fromBytes(bytes, filename: file.path.split('/').last),
      ));
    }

    // Attach audio parts
    for (final file in audioParts) {
      final bytes = await file.readAsBytes();
      formData.files.add(MapEntry(
        'audioParts',
        MultipartFile.fromBytes(bytes, filename: file.path.split('/').last),
      ));
    }

    // Attach video parts
    for (final file in videoParts) {
      final bytes = await file.readAsBytes();
      formData.files.add(MapEntry(
        'videoParts',
        MultipartFile.fromBytes(bytes, filename: file.path.split('/').last),
      ));
    }

    final response = await dio.post(
      '${ApiConstants.bookVariants}/$variantId/formats',
      options: await _authOptions(contentType: 'multipart/form-data'),
      data: formData,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add formats. Status: ${response.statusCode}');
    }
    final rawData = response.data;
    final json =
        (rawData is Map<String, dynamic> && rawData.containsKey('data'))
            ? rawData['data']
            : rawData;
    return BookVariantModel.fromJson(json);
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
