part of 'borrow_order_bloc.dart';

sealed class BorrowOrderEvent extends Equatable {
  const BorrowOrderEvent();
  @override
  List<Object?> get props => [];
}

final class LoadDraftOrder extends BorrowOrderEvent {}

final class AddBookToCart extends BorrowOrderEvent {
  final String bookId;
  const AddBookToCart(this.bookId);
  @override
  List<Object?> get props => [bookId];
}

final class RemoveBookFromCart extends BorrowOrderEvent {
  final String bookRequestId;
  const RemoveBookFromCart(this.bookRequestId);
  @override
  List<Object?> get props => [bookRequestId];
}

final class SubmitBorrowOrder extends BorrowOrderEvent {
  final FulfillmentMethod fulfillmentMethod;
  final String? address;
  final String? libraryId;
  const SubmitBorrowOrder({
    required this.fulfillmentMethod,
    this.address,
    this.libraryId,
  });
  @override
  List<Object?> get props => [fulfillmentMethod, address, libraryId];
}

final class LoadMyOrders extends BorrowOrderEvent {}

final class CancelBorrowOrder extends BorrowOrderEvent {
  final String orderId;
  final String? note;
  const CancelBorrowOrder(this.orderId, {this.note});
  @override
  List<Object?> get props => [orderId, note];
}

final class CreateOrderPayment extends BorrowOrderEvent {
  final String orderId;
  const CreateOrderPayment(this.orderId);
  @override
  List<Object?> get props => [orderId];
}

final class VerifyOrderPayment extends BorrowOrderEvent {
  final String orderId;
  final String paymentId;
  final String razorpayOrderId;
  final String signature;
  const VerifyOrderPayment({
    required this.orderId,
    required this.paymentId,
    required this.razorpayOrderId,
    required this.signature,
  });
  @override
  List<Object?> get props => [orderId, paymentId, razorpayOrderId, signature];
}
