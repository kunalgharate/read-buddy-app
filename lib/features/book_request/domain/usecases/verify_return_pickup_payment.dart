import '../repositories/book_request_repository.dart';

class VerifyReturnPickupPaymentUsecase {
  final BookRequestRepository repository;

  VerifyReturnPickupPaymentUsecase(this.repository);

  Future<void> call(
    String id, {
    required String paymentId,
    required String orderId,
    required String signature,
    required String pickupAddress,
  }) =>
      repository.verifyReturnPickupPayment(
        id,
        paymentId: paymentId,
        orderId: orderId,
        signature: signature,
        pickupAddress: pickupAddress,
      );
}
