import '../repositories/book_request_repository.dart';

class CreateBookRequestUsecase {
  final BookRequestRepository repository;

  CreateBookRequestUsecase(this.repository);

  Future<void> call({
    required String bookId,
    required String name,
    required String phone,
    required String address,
    required String pincode,
    required String fulfillmentMethod,
    String? preferredDate,
    String? preferredTime,
  }) =>
      repository.createBookRequest(
        bookId: bookId,
        name: name,
        phone: phone,
        address: address,
        pincode: pincode,
        fulfillmentMethod: fulfillmentMethod,
        preferredDate: preferredDate,
        preferredTime: preferredTime,
      );
}
