import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/book_request_entity.dart';
import '../../domain/usecases/get_my_book_requests.dart';
import '../../domain/usecases/cancel_book_request.dart';

// Events
abstract class MyRequestsEvent {}

class LoadMyRequests extends MyRequestsEvent {}

class CancelRequest extends MyRequestsEvent {
  final String requestId;
  CancelRequest(this.requestId);
}

// States
abstract class MyRequestsState {}

class MyRequestsInitial extends MyRequestsState {}

class MyRequestsLoading extends MyRequestsState {}

class MyRequestsLoaded extends MyRequestsState {
  final List<BookRequestEntity> requests;
  MyRequestsLoaded(this.requests);
}

class MyRequestsError extends MyRequestsState {
  final String message;
  MyRequestsError(this.message);
}

class CancelRequestLoading extends MyRequestsState {
  final List<BookRequestEntity> requests;
  final String cancellingId;
  CancelRequestLoading(this.requests, this.cancellingId);
}

// BLoC
class MyRequestsBloc extends Bloc<MyRequestsEvent, MyRequestsState> {
  final GetMyBookRequestsUsecase getMyBookRequests;
  final CancelBookRequestUsecase cancelBookRequest;

  MyRequestsBloc({
    required this.getMyBookRequests,
    required this.cancelBookRequest,
  }) : super(MyRequestsInitial()) {
    on<LoadMyRequests>((event, emit) async {
      emit(MyRequestsLoading());
      try {
        final requests = await getMyBookRequests();
        emit(MyRequestsLoaded(requests));
      } catch (e) {
        emit(MyRequestsError('Failed to load requests: $e'));
      }
    });

    on<CancelRequest>((event, emit) async {
      final current = state;
      if (current is! MyRequestsLoaded) return;
      emit(CancelRequestLoading(current.requests, event.requestId));
      try {
        await cancelBookRequest(event.requestId);
        final updated = current.requests
            .where((r) => r.id != event.requestId)
            .toList();
        emit(MyRequestsLoaded(updated));
      } catch (e) {
        emit(MyRequestsLoaded(current.requests));
        emit(MyRequestsError('Failed to cancel request: $e'));
      }
    });
  }
}
