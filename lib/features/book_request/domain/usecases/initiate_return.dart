import '../repositories/book_request_repository.dart';

class InitiateReturnUsecase {
  final BookRequestRepository repository;

  InitiateReturnUsecase(this.repository);

  Future<void> call(String id, String returnMethod, {String? returnBranchId}) =>
      repository.initiateReturn(id, returnMethod, returnBranchId: returnBranchId);
}
