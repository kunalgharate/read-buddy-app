import '../entities/borrow_order_entity.dart';

abstract class BorrowOrderRepository {
  Future<BorrowOrderEntity> getMyDraft();
  Future<BorrowOrderEntity> addBook({
    required String bookId,
    required String variantId,
    required String formatId,
    String? libraryId,
  });
  Future<BorrowOrderEntity> removeBook(String bookRequestId);
  Future<BorrowOrderEntity> submitOrder({
    required FulfillmentMethod fulfillmentMethod,
    String? address,
    String? libraryId,
  });
  Future<List<BorrowOrderEntity>> getMyOrders();
  Future<BorrowOrderEntity> cancelOrder(String orderId, {String? note});
  Future<Map<String, dynamic>> createPayment(String orderId);
  Future<void> verifyPayment({
    required String orderId,
    required String paymentId,
    required String razorpayOrderId,
    required String signature,
  });
}
