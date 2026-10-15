import '../entities/pickup_details_entity.dart';
import '../repositories/book_request_repository.dart';

class InitiateReturnUsecase {
  final BookRequestRepository repository;

  InitiateReturnUsecase(this.repository);

  Future<void> call(
    String id, {
    required String returnMethod,
    String? returnBranchId,
    PickupDetailsEntity? pickup,
  }) =>
      repository.initiateReturn(
        id,
        returnMethod: returnMethod,
        returnBranchId: returnBranchId,
        pickup: pickup,
      );
}
