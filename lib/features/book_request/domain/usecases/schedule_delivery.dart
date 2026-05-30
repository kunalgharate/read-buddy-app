import '../repositories/book_request_repository.dart';

class ScheduleDeliveryUsecase {
  final BookRequestRepository repository;

  ScheduleDeliveryUsecase(this.repository);

  Future<void> call({
    required String requestId,
    required String name,
    required String phone,
    required String address,
    required String pincode,
    required String preferredDate,
    required String preferredTime,
  }) =>
      repository.scheduleDelivery(
        requestId,
        name,
        phone,
        address,
        pincode,
        preferredDate,
        preferredTime,
      );
}
