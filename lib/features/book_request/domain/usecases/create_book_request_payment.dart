import '../entities/request_payment_intent.dart';
import '../repositories/book_request_repository.dart';

class CreateBookRequestPaymentUsecase {
  final BookRequestRepository repository;

  CreateBookRequestPaymentUsecase(this.repository);

  Future<RequestPaymentIntent> call(String requestId) =>
      repository.createBookRequestPayment(requestId);
}
