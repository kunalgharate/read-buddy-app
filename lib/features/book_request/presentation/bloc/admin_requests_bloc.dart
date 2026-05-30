import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/book_request_entity.dart';
import '../../domain/usecases/get_all_book_requests.dart';
import '../../domain/usecases/accept_book_request.dart';
import '../../domain/usecases/decline_book_request.dart';
import '../../domain/usecases/update_request_status.dart';

// ─── Events ────────────────────────────────────────────────────────────────

abstract class AdminRequestsEvent {}

class LoadAllRequests extends AdminRequestsEvent {}

class AcceptRequest extends AdminRequestsEvent {
  final String requestId;
  AcceptRequest(this.requestId);
}

class UpdateRequestStatus extends AdminRequestsEvent {
  final String requestId;
  final String status;
  UpdateRequestStatus(this.requestId, this.status);
}

class DeclineRequest extends AdminRequestsEvent {
  final String requestId;
  final String reason;
  DeclineRequest(this.requestId, this.reason);
}

// ─── States ────────────────────────────────────────────────────────────────

abstract class AdminRequestsState {}

class AdminRequestsInitial extends AdminRequestsState {}

class AdminRequestsLoading extends AdminRequestsState {}

class AdminRequestsLoaded extends AdminRequestsState {
  final List<BookRequestEntity> requests;
  AdminRequestsLoaded(this.requests);
}

class AdminRequestsError extends AdminRequestsState {
  final String message;
  AdminRequestsError(this.message);
}

/// Emitted while a single accept/decline action is in progress.
/// Carries the full list so the UI doesn't go blank.
class AdminRequestActionLoading extends AdminRequestsState {
  final List<BookRequestEntity> requests;
  final String actionId;
  AdminRequestActionLoading(this.requests, this.actionId);
}

class AdminRequestActionSuccess extends AdminRequestsState {
  final List<BookRequestEntity> requests;
  final String message;
  AdminRequestActionSuccess(this.requests, this.message);
}

class AdminRequestActionError extends AdminRequestsState {
  final List<BookRequestEntity> requests;
  final String message;
  AdminRequestActionError(this.requests, this.message);
}

// ─── Bloc ──────────────────────────────────────────────────────────────────

class AdminRequestsBloc
    extends Bloc<AdminRequestsEvent, AdminRequestsState> {
  final GetAllBookRequestsUsecase getAllBookRequests;
  final AcceptBookRequestUsecase acceptBookRequest;
  final DeclineBookRequestUsecase declineBookRequest;
  final UpdateRequestStatusUsecase updateRequestStatus;

  AdminRequestsBloc({
    required this.getAllBookRequests,
    required this.acceptBookRequest,
    required this.declineBookRequest,
    required this.updateRequestStatus,
  }) : super(AdminRequestsInitial()) {
    on<LoadAllRequests>(_onLoadAll);
    on<AcceptRequest>(_onAccept);
    on<DeclineRequest>(_onDecline);
    on<UpdateRequestStatus>(_onUpdateStatus);
  }

  Future<void> _onLoadAll(
      LoadAllRequests event, Emitter<AdminRequestsState> emit) async {
    emit(AdminRequestsLoading());
    try {
      final requests = await getAllBookRequests();
      emit(AdminRequestsLoaded(requests));
    } catch (e) {
      emit(AdminRequestsError('Failed to load requests: $e'));
    }
  }

  Future<void> _onAccept(
      AcceptRequest event, Emitter<AdminRequestsState> emit) async {
    final currentList = _currentList();
    emit(AdminRequestActionLoading(currentList, event.requestId));
    try {
      await acceptBookRequest(event.requestId);
      // Reload the list after action
      final updated = await getAllBookRequests();
      emit(AdminRequestActionSuccess(updated, 'Request accepted'));
    } catch (e) {
      emit(AdminRequestActionError(currentList, 'Failed to accept: $e'));
    }
  }

  Future<void> _onDecline(
      DeclineRequest event, Emitter<AdminRequestsState> emit) async {
    final currentList = _currentList();
    emit(AdminRequestActionLoading(currentList, event.requestId));
    try {
      await declineBookRequest(event.requestId, reason: event.reason);
      final updated = await getAllBookRequests();
      emit(AdminRequestActionSuccess(updated, 'Request declined'));
    } catch (e) {
      emit(AdminRequestActionError(currentList, 'Failed to decline: $e'));
    }
  }

  Future<void> _onUpdateStatus(
      UpdateRequestStatus event, Emitter<AdminRequestsState> emit) async {
    final currentList = _currentList();
    emit(AdminRequestActionLoading(currentList, event.requestId));
    try {
      await updateRequestStatus(event.requestId, event.status);
      final updated = await getAllBookRequests();
      emit(AdminRequestActionSuccess(
          updated, 'Status updated to ${event.status}'));
    } catch (e) {
      emit(AdminRequestActionError(
          currentList, 'Failed to update status: $e'));
    }
  }

  List<BookRequestEntity> _currentList() {
    final s = state;
    if (s is AdminRequestsLoaded) return s.requests;
    if (s is AdminRequestActionLoading) return s.requests;
    if (s is AdminRequestActionSuccess) return s.requests;
    if (s is AdminRequestActionError) return s.requests;
    return [];
  }
}
