import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/book_request_entity.dart';
import '../../domain/usecases/get_book_detail.dart';
import '../../domain/usecases/create_book_request.dart';
import '../../domain/usecases/get_library_details.dart';
import '../../domain/usecases/schedule_pickup.dart';
import '../../domain/usecases/schedule_delivery.dart';
import '../../domain/usecases/update_request_status.dart';
import '../../domain/usecases/initiate_return.dart';
import 'book_request_event.dart';
import 'book_request_state.dart';

class BookRequestBloc extends Bloc<BookRequestEvent, BookRequestState> {
  final GetBookDetailUsecase getBookDetail;
  final CreateBookRequestUsecase createBookRequest;
  final GetLibraryDetailsUsecase getLibraryDetails;
  final SchedulePickupUsecase schedulePickup;
  final ScheduleDeliveryUsecase scheduleDelivery;
  final UpdateRequestStatusUsecase updateRequestStatus;
  final InitiateReturnUsecase initiateReturn;

  BookRequestBloc({
    required this.getBookDetail,
    required this.createBookRequest,
    required this.getLibraryDetails,
    required this.schedulePickup,
    required this.scheduleDelivery,
    required this.updateRequestStatus,
    required this.initiateReturn,
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
      if (event.isReturn) {
        // RETURN FLOW: the backend initiate-return endpoint requires the
        // request to still be in 'delivered' status. Calling schedule-pickup
        // first would flip the status to 'pickup_scheduled' and make
        // initiate-return fail (400). So for returns we call initiate-return
        // directly with the chosen method (DROP_OFF / PICKUP), which is the
        // only call that correctly transitions the request to 'returning'.
        final method = event.returnMethod;
        if (method != null && method.isNotEmpty) {
          await initiateReturn(event.details.requestId, method);
        } else {
          await updateRequestStatus(event.details.requestId, 'returning');
        }
        // Reflect the requested return without an extra fetch. The
        // PickupScheduled listener only uses this to show a confirmation
        // message and pop, so a minimal entity is sufficient.
        emit(PickupScheduled(
          BookRequestEntity(
            id: event.details.requestId,
            status: 'returning',
            fulfillmentMethod: '',
            paymentStatus: '',
            requestDate: '',
            returnMethod: method,
          ),
        ));
        return;
      }

      final updated = await schedulePickup(event.details);
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
