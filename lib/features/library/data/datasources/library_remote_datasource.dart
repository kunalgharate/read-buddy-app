import 'package:dio/dio.dart';
import 'package:read_buddy_app/core/network/api_constants.dart';
import '../models/library_model.dart';

abstract class LibraryRemoteDataSource {
  Future<List<LibraryModel>> getLibraries(
      {String? city, int? page, int? limit});
  Future<List<LibraryModel>> getLibraryDetails();
  Future<List<LibraryModel>> getSuperLibraries();
  Future<LibraryModel> getLibraryById(String id);
  Future<LibraryModel> createLibrary(Map<String, dynamic> data);
  Future<LibraryModel> updateLibrary(String id, Map<String, dynamic> data);
  Future<void> deleteLibrary(String id);
  Future<LibraryModel> toggleSuperLibrary(String id);
  Future<void> assignLibrarian(String userId, String libraryId);
  Future<void> unassignLibrarian(String userId);
  Future<List<Map<String, dynamic>>> getLibrarians();
  Future<List<Map<String, dynamic>>> getLibrariansForLibrary(String libraryId);
}

class LibraryRemoteDataSourceImpl implements LibraryRemoteDataSource {
  final Dio _dio;

  LibraryRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<LibraryModel>> getLibraries({
    String? city,
    int? page,
    int? limit,
  }) async {
    final queryParams = <String, dynamic>{};
    if (city != null && city.isNotEmpty) queryParams['city'] = city;
    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['limit'] = limit;

    final response = await _dio.get(
      ApiConstants.libraries,
      queryParameters: queryParams,
    );

    final data = response.data;
    final list = (data['libraries'] as List?) ?? [];
    return list
        .map((json) => LibraryModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<LibraryModel>> getLibraryDetails() async {
    final response = await _dio.get(ApiConstants.libraryDetails);
    final data = response.data;
    final list = (data['libraries'] as List?) ?? [];
    return list
        .map((json) => LibraryModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<LibraryModel>> getSuperLibraries() async {
    final response = await _dio.get(ApiConstants.superLibraries);
    final data = response.data;
    final list = (data['libraries'] as List?) ?? [];
    return list
        .map((json) => LibraryModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<LibraryModel> getLibraryById(String id) async {
    final response = await _dio.get('${ApiConstants.libraries}/$id');
    final data = response.data;
    final json = data['library'] ?? data;
    return LibraryModel.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<LibraryModel> createLibrary(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiConstants.libraries, data: data);
    final responseData = response.data;
    final json = responseData['library'] ?? responseData;
    return LibraryModel.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<LibraryModel> updateLibrary(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response =
        await _dio.put('${ApiConstants.libraries}/$id', data: data);
    final responseData = response.data;
    final json = responseData['library'] ?? responseData;
    return LibraryModel.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<void> deleteLibrary(String id) async {
    await _dio.delete('${ApiConstants.libraries}/$id');
  }

  @override
  Future<LibraryModel> toggleSuperLibrary(String id) async {
    final response = await _dio.patch(
      '${ApiConstants.libraries}/$id/toggle-super',
    );
    final data = response.data;
    final json = data['library'] ?? data;
    return LibraryModel.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<void> assignLibrarian(String userId, String libraryId) async {
    await _dio.patch(
      '${ApiConstants.adminUsers}/$userId/assign-library',
      data: {'libraryId': libraryId},
    );
  }

  @override
  Future<void> unassignLibrarian(String userId) async {
    await _dio.patch('${ApiConstants.adminUsers}/$userId/unassign-library');
  }

  @override
  Future<List<Map<String, dynamic>>> getLibrarians() async {
    final response = await _dio.get(ApiConstants.adminLibrarians);
    final data = response.data;
    return List<Map<String, dynamic>>.from(data['librarians'] ?? []);
  }

  @override
  Future<List<Map<String, dynamic>>> getLibrariansForLibrary(
    String libraryId,
  ) async {
    final response = await _dio.get(
      '${ApiConstants.adminLibrariesPath}/$libraryId/librarians',
    );
    final data = response.data;
    return List<Map<String, dynamic>>.from(data['librarians'] ?? []);
  }
}
