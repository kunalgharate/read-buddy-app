import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_book_detail.dart';
import '../../domain/usecases/create_book_request.dart';
import '../../domain/usecases/get_library_details.dart';
import '../../domain/usecases/schedule_pickup.dart';
import '../../domain/usecases/set_fulfillment.dart';
import '../../domain/usecases/confirm_payment.dart';
import 'book_request_event.dart';
import 'book_request_state.dart';

class BookRequestBloc extends Bloc<BookRequestEvent, BookRequestState> {
  final GetBookDetailUsecase getBookDetail;
  final CreateBookRequestUsecase createBookRequest;
  final GetLibraryDetailsUsecase getLibraryDetails;
  final SchedulePickupUsecase schedulePickup;
  final SetFulfillmentUsecase setFulfillment;
  final ConfirmPaymentUsecase confirmPayment;

  BookRequestBloc({
    required this.getBookDetail,
    required this.createBookRequest,
    required this.getLibraryDetails,
    required this.schedulePickup,
    required this.setFulfillment,
    required this.confirmPayment,
  }) : super(BookRequestInitial()) {
    on<LoadBookDetail>(_onLoadBookDetail);
    on<CreateBookRequest>(_onCreateBookRequest);
    on<LoadLibraryDetails>(_onLoadLibraryDetails);
    on<SchedulePickup>(_onSchedulePickup);
    on<SetDeliveryFulfillment>(_onSetDeliveryFulfillment);
    on<ConfirmDeliveryPayment>(_onConfirmDeliveryPayment);
  }

  Future<void> _onLoadBookDetail(
    LoadBookDetail event,
    Emitter<BookRequestState> emit,
  ) async {
    emit(BookRequestLoading());
    try {
      final book = await getBookDetail(event.bookId);
      emit(BookDetailLoaded(book));
    } catch (e) {
      emit(BookRequestError('Failed to load book details: $e'));
    }
  }

  Future<void> _onCreateBookRequest(
    CreateBookRequest event,
    Emitter<BookRequestState> emit,
  ) async {
    emit(BookRequestCreating());
    try {
      await createBookRequest(event.bookId);
      emit(BookRequestCreated());
    } catch (e) {
      emit(BookRequestError('Failed to create book request: $e'));
    }
  }

  Future<void> _onLoadLibraryDetails(
    LoadLibraryDetails event,
    Emitter<BookRequestState> emit,
  ) async {
    emit(LibraryDetailsLoading());
    try {
      final library = await getLibraryDetails();
      emit(LibraryDetailsLoaded(library));
    } catch (e) {
      emit(LibraryDetailsError('Failed to load library details: $e'));
    }
  }

  Future<void> _onSchedulePickup(
    SchedulePickup event,
    Emitter<BookRequestState> emit,
  ) async {
    emit(PickupScheduling());
    try {
      final updated = await schedulePickup(event.details);
      emit(PickupScheduled(updated));
    } catch (e) {
      emit(PickupScheduleError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onSetDeliveryFulfillment(
    SetDeliveryFulfillment event,
    Emitter<BookRequestState> emit,
  ) async {
    emit(DeliveryFulfillmentLoading());
    try {
      await setFulfillment(
        requestId: event.requestId,
        name: event.name,
        phone: event.phone,
        address: event.address,
      );
      emit(DeliveryFulfillmentSet());
    } catch (e) {
      emit(DeliveryError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onConfirmDeliveryPayment(
    ConfirmDeliveryPayment event,
    Emitter<BookRequestState> emit,
  ) async {
    emit(DeliveryPaymentLoading());
    try {
      await confirmPayment(
        requestId: event.requestId,
        amount: event.amount,
      );
      emit(DeliveryPaymentDone());
    } catch (e) {
      emit(DeliveryError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
