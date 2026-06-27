import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_book_detail.dart';
import '../../domain/usecases/create_book_request.dart';
import '../../domain/usecases/get_library_details.dart';
import '../../domain/usecases/schedule_pickup.dart';
import '../../domain/usecases/schedule_delivery.dart';
import '../../domain/usecases/update_request_status.dart';
import 'book_request_event.dart';
import 'book_request_state.dart';

class BookRequestBloc extends Bloc<BookRequestEvent, BookRequestState> {
  final GetBookDetailUsecase getBookDetail;
  final CreateBookRequestUsecase createBookRequest;
  final GetLibraryDetailsUsecase getLibraryDetails;
  final SchedulePickupUsecase schedulePickup;
  final ScheduleDeliveryUsecase scheduleDelivery;
  final UpdateRequestStatusUsecase updateRequestStatus;

  BookRequestBloc({
    required this.getBookDetail,
    required this.createBookRequest,
    required this.getLibraryDetails,
    required this.schedulePickup,
    required this.scheduleDelivery,
    required this.updateRequestStatus,
  }) : super(BookRequestInitial()) {
    on<LoadBookDetail>(_onLoadBookDetail);
    on<CreateBookRequest>(_onCreateBookRequest);
    on<LoadLibraryDetails>(_onLoadLibraryDetails);
    on<SchedulePickup>(_onSchedulePickup);
    on<ScheduleDelivery>(_onScheduleDelivery);
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
      final requestId = await createBookRequest(
        event.bookId,
        event.fulfillmentMethod,
        deliveryName: event.deliveryName,
        deliveryPhone: event.deliveryPhone,
        deliveryAddress: event.deliveryAddress,
        deliveryPincode: event.deliveryPincode,
        deliveryPreferredDate: event.deliveryPreferredDate,
      );
      emit(BookRequestCreated(requestId: requestId));
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
      if (event.isReturn) {
        await updateRequestStatus(event.details.requestId, 'returning');
      }
      emit(PickupScheduled(updated));
    } catch (e) {
      emit(PickupScheduleError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  // Step 1: just move to step 2, no API call
  Future<void> _onScheduleDelivery(
    ScheduleDelivery event,
    Emitter<BookRequestState> emit,
  ) async {
    emit(DeliveryScheduled());
  }

  // Step 2: directly call schedule delivery
  Future<void> _onConfirmDeliveryPayment(
    ConfirmDeliveryPayment event,
    Emitter<BookRequestState> emit,
  ) async {
    emit(DeliveryPaymentLoading());
    try {
      await scheduleDelivery(
        requestId: event.requestId,
        name: event.name,
        phone: event.phone,
        address: event.address,
        pincode: event.pincode,
        preferredDate: event.preferredDate,
        preferredTime: event.preferredTime,
      );
      emit(DeliveryPaymentDone());
    } catch (e) {
      emit(DeliveryError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
