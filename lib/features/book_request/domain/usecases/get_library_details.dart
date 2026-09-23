import '../entities/library_entity.dart';
import '../repositories/book_request_repository.dart';

class GetLibraryDetailsUsecase {
  final BookRequestRepository repository;

  GetLibraryDetailsUsecase(this.repository);

  Future<LibraryEntity> call({
    String? preferredLibraryId,
    double? userLat,
    double? userLng,
  }) =>
      repository.getLibraryDetails(
        preferredLibraryId: preferredLibraryId,
        userLat: userLat,
        userLng: userLng,
      );
}
