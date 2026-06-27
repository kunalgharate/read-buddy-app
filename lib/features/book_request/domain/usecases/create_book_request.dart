import '../repositories/book_request_repository.dart';

class CreateBookRequestUsecase {
  final BookRequestRepository repository;

  CreateBookRequestUsecase(this.repository);

  Future<String> call(
    String bookId,
    String fulfillmentMethod, {
    String? deliveryName,
    String? deliveryPhone,
    String? deliveryAddress,
    String? deliveryPincode,
    String? deliveryPreferredDate,
  }) =>
      repository.createBookRequest(
        bookId,
        fulfillmentMethod,
        deliveryName: deliveryName,
        deliveryPhone: deliveryPhone,
        deliveryAddress: deliveryAddress,
        deliveryPincode: deliveryPincode,
        deliveryPreferredDate: deliveryPreferredDate,
      );
}
