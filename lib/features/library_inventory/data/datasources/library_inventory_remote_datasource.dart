import 'package:dio/dio.dart';
import 'package:read_buddy_app/core/network/api_constants.dart';
import '../models/library_inventory_model.dart';

abstract class LibraryInventoryRemoteDataSource {
  /// Admin: Add a book to a library's inventory.
  Future<LibraryInventoryModel> addBookToLibrary({
    required String libraryId,
    required String bookId,
    required String variantId,
    required String formatType,
    required int totalCopies,
  });

  /// Admin: List inventory for a library (with optional search).
  Future<List<LibraryInventoryModel>> getLibraryInventory({
    required String libraryId,
    String? search,
    int? page,
    int? limit,
  });

  /// Admin: Update copy count for an inventory record.
  Future<LibraryInventoryModel> updateInventory({
    required String id,
    required int totalCopies,
  });

  /// Admin: Remove a book from a library's inventory.
  Future<void> deleteInventory(String id);

  /// User: Browse books available in a city.
  Future<List<CityBookModel>> browseByCity({
    required String city,
    String? search,
    int? page,
    int? limit,
    double? lat,
    double? lng,
  });
}

class LibraryInventoryRemoteDataSourceImpl
    implements LibraryInventoryRemoteDataSource {
  final Dio _dio;

  LibraryInventoryRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<LibraryInventoryModel> addBookToLibrary({
    required String libraryId,
    required String bookId,
    required String variantId,
    required String formatType,
    required int totalCopies,
  }) async {
    final response = await _dio.post(
      ApiConstants.libraryInventory,
      data: {
        'libraryId': libraryId,
        'bookId': bookId,
        'variantId': variantId,
        'formatType': formatType,
        'totalCopies': totalCopies,
      },
    );
    final data = response.data;
    final json = data['inventory'] ?? data;
    return LibraryInventoryModel.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<List<LibraryInventoryModel>> getLibraryInventory({
    required String libraryId,
    String? search,
    int? page,
    int? limit,
  }) async {
    final queryParams = <String, dynamic>{'libraryId': libraryId};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['limit'] = limit;

    final response = await _dio.get(
      ApiConstants.libraryInventory,
      queryParameters: queryParams,
    );
    final data = response.data;
    final list = (data['inventory'] as List?) ?? [];
    return list
        .map(
          (json) =>
              LibraryInventoryModel.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<LibraryInventoryModel> updateInventory({
    required String id,
    required int totalCopies,
  }) async {
    final response = await _dio.patch(
      ApiConstants.libraryInventoryById(id),
      data: {'totalCopies': totalCopies},
    );
    final data = response.data;
    final json = data['inventory'] ?? data;
    return LibraryInventoryModel.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<void> deleteInventory(String id) async {
    await _dio.delete(ApiConstants.libraryInventoryById(id));
  }

  @override
  Future<List<CityBookModel>> browseByCity({
    required String city,
    String? search,
    int? page,
    int? limit,
    double? lat,
    double? lng,
  }) async {
    final queryParams = <String, dynamic>{'city': city};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['limit'] = limit;
    if (lat != null) queryParams['lat'] = lat;
    if (lng != null) queryParams['lng'] = lng;

    var books = await _fetchCityBooks(queryParams);

    // Libraries may be stored under a differently-cased/spaced city name than
    // the one selected (e.g. "hyderabad" vs "Hyderabad", or with a trailing
    // state). Retry with common normalizations so those books still surface
    // instead of the city appearing to have no books at all.
    if (books.isEmpty) {
      for (final variant in _cityVariants(city)) {
        if (variant == city) continue;
        final retry = Map<String, dynamic>.from(queryParams)..['city'] = variant;
        books = await _fetchCityBooks(retry);
        if (books.isNotEmpty) break;
      }
    }
    return books;
  }

  Future<List<CityBookModel>> _fetchCityBooks(
    Map<String, dynamic> queryParams,
  ) async {
    final response = await _dio.get(
      ApiConstants.libraryInventoryBrowse,
      queryParameters: queryParams,
    );
    final data = response.data;
    final list = (data['books'] as List?) ?? [];
    return list
        .map((json) => CityBookModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Iterable<String> _cityVariants(String city) {
    final trimmed = city.trim();
    final titleCased = trimmed
        .split(RegExp(r'\s+'))
        .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
        .join(' ');
    final withoutSuffix = trimmed.split(',').first.trim();
    return {
      withoutSuffix,
      titleCased,
      titleCased.split(',').first.trim(),
      trimmed.toLowerCase(),
    };
  }
}
