import '../entities/library_entity.dart';

abstract class LibraryRepository {
  Future<List<LibraryEntity>> getLibraries({String? city, int? page, int? limit});
  Future<List<LibraryEntity>> getLibraryDetails();
  Future<List<LibraryEntity>> getSuperLibraries();
  Future<LibraryEntity> getLibraryById(String id);
  Future<LibraryEntity> createLibrary(Map<String, dynamic> data);
  Future<LibraryEntity> updateLibrary(String id, Map<String, dynamic> data);
  Future<void> deleteLibrary(String id);
  Future<LibraryEntity> toggleSuperLibrary(String id);
  Future<void> assignLibrarian(String userId, String libraryId);
  Future<void> unassignLibrarian(String userId);
  Future<List<Map<String, dynamic>>> getLibrarians();
  Future<List<Map<String, dynamic>>> getLibrariansForLibrary(String libraryId);
}
