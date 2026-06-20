import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/usecases/get_my_notifications.dart';

// ─── Events ────────────────────────────────────────────────────────────────

abstract class NotificationEvent {}

class LoadMyNotifications extends NotificationEvent {}

// ─── States ────────────────────────────────────────────────────────────────

abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<Map<String, dynamic>> notifications;
  NotificationLoaded(this.notifications);
}

class NotificationError extends NotificationState {
  final String message;
  NotificationError(this.message);
}

// ─── Bloc ──────────────────────────────────────────────────────────────────

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetMyNotificationsUsecase getMyNotifications;
  final NotificationRepository repository;

  NotificationBloc({
    required this.getMyNotifications,
    required this.repository,
  }) : super(NotificationInitial()) {
    on<LoadMyNotifications>(_onLoad);
  }

  Future<void> _onLoad(
    LoadMyNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    try {
      final notifications = await getMyNotifications();
      emit(NotificationLoaded(notifications));
    } catch (e) {
      emit(NotificationError('Failed to load notifications: $e'));
    }
  }
}
