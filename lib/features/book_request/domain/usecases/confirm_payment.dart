import '../repositories/book_request_repository.dart';

class ConfirmPaymentUsecase {
  final BookRequestRepository repository;

  ConfirmPaymentUsecase(this.repository);

  Future<void> call({required String requestId, required int amount}) =>
      repository.confirmPayment(requestId, amount);
}
