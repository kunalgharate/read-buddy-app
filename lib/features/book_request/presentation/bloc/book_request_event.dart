import '../../domain/entities/pickup_details_entity.dart';

abstract class BookRequestEvent {}

class LoadBookDetail extends BookRequestEvent {
  final String bookId;
  LoadBookDetail(this.bookId);
}

class CreateBookRequest extends BookRequestEvent {
  final String bookId;
  final String fulfillmentMethod;
  final String? deliveryName;
  final String? deliveryPhone;
  final String? deliveryAddress;
  final String? deliveryPincode;
  final String? deliveryPreferredDate;

  CreateBookRequest(
    this.bookId, {
    this.fulfillmentMethod = 'pickup',
    this.deliveryName,
    this.deliveryPhone,
    this.deliveryAddress,
    this.deliveryPincode,
    this.deliveryPreferredDate,
  });
}

class LoadLibraryDetails extends BookRequestEvent {}

class SchedulePickup extends BookRequestEvent {
  final PickupDetailsEntity details;
  final bool isReturn;
  SchedulePickup(this.details, {this.isReturn = false});
}

class ScheduleDelivery extends BookRequestEvent {
  final String requestId;
  final String name;
  final String phone;
  final String address;
  final String pincode;
  final String preferredDate;
  final String preferredTime;
  ScheduleDelivery({
    required this.requestId,
    required this.name,
    required this.phone,
    required this.address,
    required this.pincode,
    required this.preferredDate,
    required this.preferredTime,
  });
}

class ConfirmDeliveryPayment extends BookRequestEvent {
  final String requestId;
  final String name;
  final String phone;
  final String address;
  final String pincode;
  final String preferredDate;
  final String preferredTime;
  final int amount;
  ConfirmDeliveryPayment({
    required this.requestId,
    required this.name,
    required this.phone,
    required this.address,
    required this.pincode,
    required this.preferredDate,
    required this.preferredTime,
    this.amount = 8000,
  });
}
