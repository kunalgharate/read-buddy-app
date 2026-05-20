import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/book_request_entity.dart';
import '../../domain/usecases/get_my_book_requests.dart';
import '../../domain/usecases/cancel_book_request.dart';
import '../../domain/usecases/update_request_status.dart';

// Events
abstract class MyRequestsEvent {}

class LoadMyRequests extends MyRequestsEvent {}

class CancelRequest extends MyRequestsEvent {
  final String requestId;
  final String reason;
  CancelRequest(this.requestId, this.reason);
}

class MarkAsDelivered extends MyRequestsEvent {
  final String requestId;
  MarkAsDelivered(this.requestId);
}

// States
abstract class MyRequestsState {}

class MyRequestsInitial extends MyRequestsState {}

class MyRequestsLoading extends MyRequestsState {}

class MyRequestsLoaded extends MyRequestsState {
  final List<BookRequestEntity> requests;
  MyRequestsLoaded(this.requests);
}

class MyRequestsError extends MyRequestsState {}

class MyRequestsCancelLoading extends MyRequestsState {
  final List<BookRequestEntity> requests;
  final String cancellingId;
  MyRequestsCancelLoading(this.requests, this.cancellingId);
}

class MyRequestsCancelError extends MyRequestsState {
  final List<BookRequestEntity> requests;
  final String message;
  MyRequestsCancelError(this.requests, this.message);
}

class MyRequestsErrorState extends MyRequestsState {
  final String message;
  MyRequestsErrorState(this.message);
}

// BLoC
class MyRequestsBloc extends Bloc<MyRequestsEvent, MyRequestsState> {
  final GetMyBookRequestsUsecase getMyBookRequests;
  final CancelBookRequestUsecase cancelBookRequest;
  final UpdateRequestStatusUsecase updateRequestStatus;

  MyRequestsBloc({
    required this.getMyBookRequests,
    required this.cancelBookRequest,
    required this.updateRequestStatus,
  }) : super(MyRequestsInitial()) {
    on<LoadMyRequests>((event, emit) async {
      emit(MyRequestsLoading());
      try {
        final requests = await getMyBookRequests();
        emit(MyRequestsLoaded(requests));
      } catch (e) {
        emit(MyRequestsErrorState('Failed to load requests: $e'));
      }
    });
    on<CancelRequest>((event, emit) async {
      final current = _currentList();
      emit(MyRequestsCancelLoading(current, event.requestId));
      try {
        await cancelBookRequest(event.requestId, event.reason);
        // Update status locally instead of reloading — keeps cancelled record visible
        final updated = current.map((r) {
          if (r.id == event.requestId) {
            return BookRequestEntity(
              id: r.id,
              userId: r.userId,
              status: 'cancelled',
              fulfillmentMethod: r.fulfillmentMethod,
              paymentStatus: r.paymentStatus,
              requestDate: r.requestDate,
              dueDate: r.dueDate,
              returnDate: r.returnDate,
              bookId: r.bookId,
              bookTitle: r.bookTitle,
              bookAuthor: r.bookAuthor,
              bookCoverUrl: r.bookCoverUrl,
              bookFormat: r.bookFormat,
              donorName: r.donorName,
              userName: r.userName,
            );
          }
          return r;
        }).toList();
        emit(MyRequestsLoaded(updated));
      } catch (e) {
        emit(MyRequestsCancelError(current, 'Failed to cancel request'));
      }
    });
    on<MarkAsDelivered>((event, emit) async {
      final current = _currentList();
      emit(MyRequestsCancelLoading(current, event.requestId));
      try {
        await updateRequestStatus(event.requestId, 'delivered');
        final updated = await getMyBookRequests();
        emit(MyRequestsLoaded(updated));
      } catch (e) {
        emit(MyRequestsCancelError(current, 'Failed to mark as delivered'));
      }
    });
  }

  List<BookRequestEntity> _currentList() {
    final s = state;
    if (s is MyRequestsLoaded) return s.requests;
    if (s is MyRequestsCancelLoading) return s.requests;
    if (s is MyRequestsCancelError) return s.requests;
    return [];
  }
}
