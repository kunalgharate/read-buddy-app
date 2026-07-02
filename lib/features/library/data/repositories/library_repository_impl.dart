import '../../domain/entities/library_entity.dart';
import '../../domain/repositories/library_repository.dart';
import '../datasources/library_remote_datasource.dart';

class LibraryRepositoryImpl implements LibraryRepository {
  final LibraryRemoteDataSource _remoteDataSource;

  LibraryRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<LibraryEntity>> getLibraries({
    String? city,
    int? page,
    int? limit,
  }) => _remoteDataSource.getLibraries(city: city, page: page, limit: limit);

  @override
  Future<List<LibraryEntity>> getLibraryDetails() =>
      _remoteDataSource.getLibraryDetails();

  @override
  Future<List<LibraryEntity>> getSuperLibraries() =>
      _remoteDataSource.getSuperLibraries();

  @override
  Future<LibraryEntity> getLibraryById(String id) =>
      _remoteDataSource.getLibraryById(id);

  @override
  Future<LibraryEntity> createLibrary(Map<String, dynamic> data) =>
      _remoteDataSource.createLibrary(data);

  @override
  Future<LibraryEntity> updateLibrary(String id, Map<String, dynamic> data) =>
      _remoteDataSource.updateLibrary(id, data);

  @override
  Future<void> deleteLibrary(String id) => _remoteDataSource.deleteLibrary(id);

  @override
  Future<LibraryEntity> toggleSuperLibrary(String id) =>
      _remoteDataSource.toggleSuperLibrary(id);

  @override
  Future<void> assignLibrarian(String userId, String libraryId) =>
      _remoteDataSource.assignLibrarian(userId, libraryId);

  @override
  Future<void> unassignLibrarian(String userId) =>
      _remoteDataSource.unassignLibrarian(userId);

  @override
  Future<List<Map<String, dynamic>>> getLibrarians() =>
      _remoteDataSource.getLibrarians();

  @override
  Future<List<Map<String, dynamic>>> getLibrariansForLibrary(
    String libraryId,
  ) => _remoteDataSource.getLibrariansForLibrary(libraryId);
}
