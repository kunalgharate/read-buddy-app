import '../entities/book_request_entity.dart';
import '../entities/pickup_details_entity.dart';
import '../repositories/book_request_repository.dart';

class SchedulePickupUsecase {
  final BookRequestRepository repository;

  SchedulePickupUsecase(this.repository);

  Future<BookRequestEntity> call(PickupDetailsEntity details) =>
      repository.schedulePickup(details);
}
