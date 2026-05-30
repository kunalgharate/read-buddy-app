import '../entities/library_entity.dart';
import '../repositories/book_request_repository.dart';

class GetLibraryDetailsUsecase {
  final BookRequestRepository repository;

  GetLibraryDetailsUsecase(this.repository);

  Future<LibraryEntity> call() => repository.getLibraryDetails();
}
