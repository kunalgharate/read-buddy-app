import '../../domain/entities/pickup_details_entity.dart';

abstract class BookRequestEvent {}

class LoadBookDetail extends BookRequestEvent {
  final String bookId;
  LoadBookDetail(this.bookId);
}

class CreateBookRequest extends BookRequestEvent {
  final String bookId;
  CreateBookRequest(this.bookId);
}

class LoadLibraryDetails extends BookRequestEvent {}

class SchedulePickup extends BookRequestEvent {
  final PickupDetailsEntity details;
  SchedulePickup(this.details);
}

class SetDeliveryFulfillment extends BookRequestEvent {
  final String requestId;
  final String name;
  final String phone;
  final String address;
  SetDeliveryFulfillment({
    required this.requestId,
    required this.name,
    required this.phone,
    required this.address,
  });
}

class ConfirmDeliveryPayment extends BookRequestEvent {
  final String requestId;
  final int amount;
  ConfirmDeliveryPayment({required this.requestId, this.amount = 8000});
}
