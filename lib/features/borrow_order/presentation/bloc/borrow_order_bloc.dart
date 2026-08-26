import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:read_buddy_app/core/utils/error_handler.dart';
import '../../domain/entities/borrow_order_entity.dart';
import '../../domain/usecases/borrow_order_usecases.dart';

part 'borrow_order_event.dart';
part 'borrow_order_state.dart';

class BorrowOrderBloc extends Bloc<BorrowOrderEvent, BorrowOrderState> {
  final GetMyDraft _getMyDraft;
  final AddBookToOrder _addBookToOrder;
  final RemoveBookFromOrder _removeBookFromOrder;
  final SubmitOrder _submitOrder;
  final GetMyOrders _getMyOrders;
  final CancelOrder _cancelOrder;
  final CreatePayment _createPayment;
  final VerifyPayment _verifyPayment;

  BorrowOrderBloc({
    required GetMyDraft getMyDraft,
    required AddBookToOrder addBookToOrder,
    required RemoveBookFromOrder removeBookFromOrder,
    required SubmitOrder submitOrder,
    required GetMyOrders getMyOrders,
    required CancelOrder cancelOrder,
    required CreatePayment createPayment,
    required VerifyPayment verifyPayment,
  })  : _getMyDraft = getMyDraft,
        _addBookToOrder = addBookToOrder,
        _removeBookFromOrder = removeBookFromOrder,
        _submitOrder = submitOrder,
        _getMyOrders = getMyOrders,
        _cancelOrder = cancelOrder,
        _createPayment = createPayment,
        _verifyPayment = verifyPayment,
        super(BorrowOrderInitial()) {
    on<LoadDraftOrder>(_onLoadDraftOrder);
    on<AddBookToCart>(_onAddBookToCart);
    on<RemoveBookFromCart>(_onRemoveBookFromCart);
    on<SubmitBorrowOrder>(_onSubmitBorrowOrder);
    on<LoadMyOrders>(_onLoadMyOrders);
    on<CancelBorrowOrder>(_onCancelBorrowOrder);
    on<CreateOrderPayment>(_onCreateOrderPayment);
    on<VerifyOrderPayment>(_onVerifyOrderPayment);
  }

  Future<void> _onLoadDraftOrder(
    LoadDraftOrder event,
    Emitter<BorrowOrderState> emit,
  ) async {
    emit(BorrowOrderLoading());
    try {
      final order = await _getMyDraft();
      emit(DraftOrderLoaded(order));
    } catch (e) {
      emit(BorrowOrderError(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> _onAddBookToCart(
    AddBookToCart event,
    Emitter<BorrowOrderState> emit,
  ) async {
    emit(BorrowOrderLoading());
    try {
      final order = await _addBookToOrder(event.bookId);
      emit(BookAddedToCart(order));
    } catch (e) {
      emit(BorrowOrderError(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> _onRemoveBookFromCart(
    RemoveBookFromCart event,
    Emitter<BorrowOrderState> emit,
  ) async {
    try {
      final order = await _removeBookFromOrder(event.bookRequestId);
      emit(BookRemovedFromCart(order));
    } catch (e) {
      emit(BorrowOrderError(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> _onSubmitBorrowOrder(
    SubmitBorrowOrder event,
    Emitter<BorrowOrderState> emit,
  ) async {
    emit(BorrowOrderLoading());
    try {
      final order = await _submitOrder(
        fulfillmentMethod: event.fulfillmentMethod,
        address: event.address,
        libraryId: event.libraryId,
      );
      emit(OrderSubmitted(order));
    } catch (e) {
      emit(BorrowOrderError(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> _onLoadMyOrders(
    LoadMyOrders event,
    Emitter<BorrowOrderState> emit,
  ) async {
    emit(BorrowOrderLoading());
    try {
      final orders = await _getMyOrders();
      emit(MyOrdersLoaded(orders));
    } catch (e) {
      emit(BorrowOrderError(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> _onCancelBorrowOrder(
    CancelBorrowOrder event,
    Emitter<BorrowOrderState> emit,
  ) async {
    try {
      final order = await _cancelOrder(event.orderId, note: event.note);
      emit(OrderCancelled(order));
    } catch (e) {
      emit(BorrowOrderError(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> _onCreateOrderPayment(
    CreateOrderPayment event,
    Emitter<BorrowOrderState> emit,
  ) async {
    emit(BorrowOrderLoading());
    try {
      final paymentData = await _createPayment(event.orderId);
      emit(PaymentCreated(paymentData));
    } catch (e) {
      emit(BorrowOrderError(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> _onVerifyOrderPayment(
    VerifyOrderPayment event,
    Emitter<BorrowOrderState> emit,
  ) async {
    emit(BorrowOrderLoading());
    try {
      await _verifyPayment(
        orderId: event.orderId,
        paymentId: event.paymentId,
        razorpayOrderId: event.razorpayOrderId,
        signature: event.signature,
      );
      emit(PaymentVerified());
    } catch (e) {
      emit(BorrowOrderError(ErrorHandler.getErrorMessage(e)));
    }
  }
}
