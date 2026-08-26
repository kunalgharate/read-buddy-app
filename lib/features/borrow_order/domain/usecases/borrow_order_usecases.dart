import '../entities/borrow_order_entity.dart';
import '../repositories/borrow_order_repository.dart';

class GetMyDraft {
  final BorrowOrderRepository _repository;
  GetMyDraft(this._repository);

  Future<BorrowOrderEntity> call() => _repository.getMyDraft();
}

class AddBookToOrder {
  final BorrowOrderRepository _repository;
  AddBookToOrder(this._repository);

  Future<BorrowOrderEntity> call(String bookId) => _repository.addBook(bookId);
}

class RemoveBookFromOrder {
  final BorrowOrderRepository _repository;
  RemoveBookFromOrder(this._repository);

  Future<BorrowOrderEntity> call(String bookRequestId) =>
      _repository.removeBook(bookRequestId);
}

class SubmitOrder {
  final BorrowOrderRepository _repository;
  SubmitOrder(this._repository);

  Future<BorrowOrderEntity> call({
    required FulfillmentMethod fulfillmentMethod,
    String? address,
    String? libraryId,
  }) =>
      _repository.submitOrder(
        fulfillmentMethod: fulfillmentMethod,
        address: address,
        libraryId: libraryId,
      );
}

class GetMyOrders {
  final BorrowOrderRepository _repository;
  GetMyOrders(this._repository);

  Future<List<BorrowOrderEntity>> call() => _repository.getMyOrders();
}

class CancelOrder {
  final BorrowOrderRepository _repository;
  CancelOrder(this._repository);

  Future<BorrowOrderEntity> call(String orderId, {String? note}) =>
      _repository.cancelOrder(orderId, note: note);
}

class CreatePayment {
  final BorrowOrderRepository _repository;
  CreatePayment(this._repository);

  Future<Map<String, dynamic>> call(String orderId) =>
      _repository.createPayment(orderId);
}

class VerifyPayment {
  final BorrowOrderRepository _repository;
  VerifyPayment(this._repository);

  Future<void> call({
    required String orderId,
    required String paymentId,
    required String razorpayOrderId,
    required String signature,
  }) =>
      _repository.verifyPayment(
        orderId: orderId,
        paymentId: paymentId,
        razorpayOrderId: razorpayOrderId,
        signature: signature,
      );
}
