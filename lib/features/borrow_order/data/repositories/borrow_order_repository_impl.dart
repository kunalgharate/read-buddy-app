import '../../domain/entities/borrow_order_entity.dart';
import '../../domain/repositories/borrow_order_repository.dart';
import '../datasources/borrow_order_remote_datasource.dart';

class BorrowOrderRepositoryImpl implements BorrowOrderRepository {
  final BorrowOrderRemoteDataSource _remoteDataSource;

  BorrowOrderRepositoryImpl(this._remoteDataSource);

  @override
  Future<BorrowOrderEntity> getMyDraft() => _remoteDataSource.getMyDraft();

  @override
  Future<BorrowOrderEntity> addBook(String bookId) =>
      _remoteDataSource.addBook(bookId);

  @override
  Future<BorrowOrderEntity> removeBook(String bookRequestId) =>
      _remoteDataSource.removeBook(bookRequestId);

  @override
  Future<BorrowOrderEntity> submitOrder({
    required FulfillmentMethod fulfillmentMethod,
    String? address,
    String? libraryId,
  }) =>
      _remoteDataSource.submitOrder(
        fulfillmentMethod: fulfillmentMethod,
        address: address,
        libraryId: libraryId,
      );

  @override
  Future<List<BorrowOrderEntity>> getMyOrders() =>
      _remoteDataSource.getMyOrders();

  @override
  Future<BorrowOrderEntity> cancelOrder(String orderId, {String? note}) =>
      _remoteDataSource.cancelOrder(orderId, note: note);

  @override
  Future<Map<String, dynamic>> createPayment(String orderId) =>
      _remoteDataSource.createPayment(orderId);

  @override
  Future<void> verifyPayment({
    required String orderId,
    required String paymentId,
    required String razorpayOrderId,
    required String signature,
  }) =>
      _remoteDataSource.verifyPayment(
        orderId: orderId,
        paymentId: paymentId,
        razorpayOrderId: razorpayOrderId,
        signature: signature,
      );
}
