import '../../domain/entities/book_detail_entity.dart';
import '../../domain/entities/book_request_entity.dart';
import '../../domain/entities/library_entity.dart';

abstract class BookRequestState {}

class BookRequestInitial extends BookRequestState {}

class BookRequestLoading extends BookRequestState {}

class BookDetailLoaded extends BookRequestState {
  final BookDetailEntity book;
  BookDetailLoaded(this.book);
}

class BookRequestCreating extends BookRequestState {}

class BookRequestCreated extends BookRequestState {}

class BookRequestError extends BookRequestState {
  final String message;
  BookRequestError(this.message);
}

class LibraryDetailsLoading extends BookRequestState {}

class LibraryDetailsLoaded extends BookRequestState {
  final LibraryEntity library;
  LibraryDetailsLoaded(this.library);
}

class LibraryDetailsError extends BookRequestState {
  final String message;
  LibraryDetailsError(this.message);
}

// ── Pickup scheduling states ──────────────────────────────────────────────────

class PickupScheduling extends BookRequestState {}

class PickupScheduled extends BookRequestState {
  final BookRequestEntity updatedRequest;
  PickupScheduled(this.updatedRequest);
}

class PickupScheduleError extends BookRequestState {
  final String message;
  PickupScheduleError(this.message);
}

// ── Delivery states ───────────────────────────────────────────────────────────

class DeliveryFulfillmentLoading extends BookRequestState {}

class DeliveryFulfillmentSet extends BookRequestState {}

class DeliveryPaymentLoading extends BookRequestState {}

class DeliveryPaymentDone extends BookRequestState {}

class DeliveryError extends BookRequestState {
  final String message;
  DeliveryError(this.message);
}
