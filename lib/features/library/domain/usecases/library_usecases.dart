import '../entities/library_entity.dart';
import '../repositories/library_repository.dart';

class GetLibraries {
  final LibraryRepository _repository;
  GetLibraries(this._repository);

  Future<List<LibraryEntity>> call({String? city, int? page, int? limit}) =>
      _repository.getLibraries(city: city, page: page, limit: limit);
}

class GetLibraryDetails {
  final LibraryRepository _repository;
  GetLibraryDetails(this._repository);

  Future<List<LibraryEntity>> call() => _repository.getLibraryDetails();
}

class GetSuperLibraries {
  final LibraryRepository _repository;
  GetSuperLibraries(this._repository);

  Future<List<LibraryEntity>> call() => _repository.getSuperLibraries();
}

class GetLibraryById {
  final LibraryRepository _repository;
  GetLibraryById(this._repository);

  Future<LibraryEntity> call(String id) => _repository.getLibraryById(id);
}

class CreateLibrary {
  final LibraryRepository _repository;
  CreateLibrary(this._repository);

  Future<LibraryEntity> call(Map<String, dynamic> data) =>
      _repository.createLibrary(data);
}

class UpdateLibrary {
  final LibraryRepository _repository;
  UpdateLibrary(this._repository);

  Future<LibraryEntity> call(String id, Map<String, dynamic> data) =>
      _repository.updateLibrary(id, data);
}

class DeleteLibrary {
  final LibraryRepository _repository;
  DeleteLibrary(this._repository);

  Future<void> call(String id) => _repository.deleteLibrary(id);
}

class ToggleSuperLibrary {
  final LibraryRepository _repository;
  ToggleSuperLibrary(this._repository);

  Future<LibraryEntity> call(String id) => _repository.toggleSuperLibrary(id);
}

class AssignLibrarian {
  final LibraryRepository _repository;
  AssignLibrarian(this._repository);

  Future<void> call(String userId, String libraryId) =>
      _repository.assignLibrarian(userId, libraryId);
}

class UnassignLibrarian {
  final LibraryRepository _repository;
  UnassignLibrarian(this._repository);

  Future<void> call(String userId) => _repository.unassignLibrarian(userId);
}

class GetLibrarians {
  final LibraryRepository _repository;
  GetLibrarians(this._repository);

  Future<List<Map<String, dynamic>>> call() => _repository.getLibrarians();
}
