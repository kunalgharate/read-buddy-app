import '../repositories/book_request_repository.dart';

class CreateReturnPickupOrderUsecase {
  final BookRequestRepository repository;

  CreateReturnPickupOrderUsecase(this.repository);

  Future<Map<String, dynamic>> call(String id) =>
      repository.createReturnPickupOrder(id);
}
