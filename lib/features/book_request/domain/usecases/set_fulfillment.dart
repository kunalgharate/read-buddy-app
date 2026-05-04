import '../repositories/book_request_repository.dart';

class SetFulfillmentUsecase {
  final BookRequestRepository repository;

  SetFulfillmentUsecase(this.repository);

  Future<void> call({
    required String requestId,
    required String name,
    required String phone,
    required String address,
  }) =>
      repository.setFulfillment(requestId, 'DELIVERY', name, phone, address);
}
