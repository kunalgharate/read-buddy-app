import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/book_request_entity.dart';
import '../../domain/usecases/get_upcoming_pickups.dart';

// ─── Events ────────────────────────────────────────────────────────────────

abstract class AdminUpcomingPickupsEvent {}

class LoadUpcomingPickups extends AdminUpcomingPickupsEvent {}

class RefreshUpcomingPickups extends AdminUpcomingPickupsEvent {}

// ─── States ────────────────────────────────────────────────────────────────

abstract class AdminUpcomingPickupsState {}

class UpcomingPickupsInitial extends AdminUpcomingPickupsState {}

class UpcomingPickupsLoading extends AdminUpcomingPickupsState {}

class UpcomingPickupsLoaded extends AdminUpcomingPickupsState {
  final List<BookRequestEntity> pickups;
  UpcomingPickupsLoaded(this.pickups);
}

class UpcomingPickupsEmpty extends AdminUpcomingPickupsState {}

class UpcomingPickupsError extends AdminUpcomingPickupsState {
  final String message;
  UpcomingPickupsError(this.message);
}

// ─── BLoC ──────────────────────────────────────────────────────────────────

class AdminUpcomingPickupsBloc
    extends Bloc<AdminUpcomingPickupsEvent, AdminUpcomingPickupsState> {
  final GetUpcomingPickupsUsecase getUpcomingPickups;

  AdminUpcomingPickupsBloc({required this.getUpcomingPickups})
      : super(UpcomingPickupsInitial()) {
    on<LoadUpcomingPickups>(_onLoad);
    on<RefreshUpcomingPickups>(_onRefresh);
  }

  Future<void> _onLoad(
    LoadUpcomingPickups event,
    Emitter<AdminUpcomingPickupsState> emit,
  ) async {
    emit(UpcomingPickupsLoading());
    await _fetchAndEmit(emit);
  }

  /// Refresh silently — does NOT emit UpcomingPickupsLoading so the UI
  /// keeps showing the current list while data is fetched in the background.
  Future<void> _onRefresh(
    RefreshUpcomingPickups event,
    Emitter<AdminUpcomingPickupsState> emit,
  ) async {
    await _fetchAndEmit(emit);
  }

  Future<void> _fetchAndEmit(
    Emitter<AdminUpcomingPickupsState> emit,
  ) async {
    try {
      final pickups = await getUpcomingPickups();
      if (pickups.isEmpty) {
        emit(UpcomingPickupsEmpty());
      } else {
        emit(UpcomingPickupsLoaded(pickups));
      }
    } catch (e) {
      emit(UpcomingPickupsError(
        e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }
}
