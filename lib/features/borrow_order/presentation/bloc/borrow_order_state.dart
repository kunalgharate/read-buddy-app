part of 'borrow_order_bloc.dart';

sealed class BorrowOrderState extends Equatable {
  const BorrowOrderState();
  @override
  List<Object?> get props => [];
}

final class BorrowOrderInitial extends BorrowOrderState {}

final class BorrowOrderLoading extends BorrowOrderState {}

final class DraftOrderLoaded extends BorrowOrderState {
  final BorrowOrderEntity order;
  const DraftOrderLoaded(this.order);
  @override
  List<Object?> get props => [order];
}

final class BookAddedToCart extends BorrowOrderState {
  final BorrowOrderEntity order;
  const BookAddedToCart(this.order);
  @override
  List<Object?> get props => [order];
}

final class BookRemovedFromCart extends BorrowOrderState {
  final BorrowOrderEntity order;
  const BookRemovedFromCart(this.order);
  @override
  List<Object?> get props => [order];
}

final class OrderSubmitted extends BorrowOrderState {
  final BorrowOrderEntity order;
  const OrderSubmitted(this.order);
  @override
  List<Object?> get props => [order];
}

final class MyOrdersLoaded extends BorrowOrderState {
  final List<BorrowOrderEntity> orders;
  const MyOrdersLoaded(this.orders);
  @override
  List<Object?> get props => [orders];
}

final class OrderCancelled extends BorrowOrderState {
  final BorrowOrderEntity order;
  const OrderCancelled(this.order);
  @override
  List<Object?> get props => [order];
}

final class PaymentCreated extends BorrowOrderState {
  final Map<String, dynamic> paymentData;
  const PaymentCreated(this.paymentData);
  @override
  List<Object?> get props => [paymentData];
}

final class PaymentVerified extends BorrowOrderState {}

final class BorrowOrderError extends BorrowOrderState {
  final String message;
  const BorrowOrderError(this.message);
  @override
  List<Object?> get props => [message];
}
