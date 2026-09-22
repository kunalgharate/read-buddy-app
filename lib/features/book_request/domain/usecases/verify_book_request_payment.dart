import '../repositories/book_request_repository.dart';

class VerifyBookRequestPaymentUsecase {
  final BookRequestRepository repository;

  VerifyBookRequestPaymentUsecase(this.repository);

  Future<void> call(
    String requestId, {
    required String paymentId,
    required String orderId,
    required String signature,
  }) =>
      repository.verifyBookRequestPayment(
        requestId,
        paymentId: paymentId,
        orderId: orderId,
        signature: signature,
      );
}
