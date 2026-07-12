import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:read_buddy_app/core/utils/error_handler.dart';
import 'package:read_buddy_app/features/library/domain/entities/library_entity.dart';
import 'package:read_buddy_app/features/librarian/data/datasources/librarian_remote_datasource.dart';

part 'librarian_event.dart';
part 'librarian_state.dart';

class LibrarianBloc extends Bloc<LibrarianEvent, LibrarianState> {
  final LibrarianRemoteDataSource _dataSource;

  LibrarianBloc(this._dataSource) : super(const LibrarianInitial()) {
    on<LoadLibrarianDashboard>(_onLoadDashboard);
    on<LoadLibrarianRequests>(_onLoadRequests);
    on<AcceptRequestEvent>(_onAcceptRequest);
    on<RejectRequestEvent>(_onRejectRequest);
    on<UpdateRequestStatusEvent>(_onUpdateRequestStatus);
    on<LoadLibrarianDonations>(_onLoadDonations);
    on<UpdateDonationStatusEvent>(_onUpdateDonationStatus);
    on<SchedulePickupEvent>(_onSchedulePickup);
  }

  Future<void> _onLoadDashboard(
    LoadLibrarianDashboard event,
    Emitter<LibrarianState> emit,
  ) async {
    emit(const LibrarianLoading());
    try {
      final library = await _dataSource.getMyLibrary();
      final stats = await _dataSource.getDashboardStats();
      emit(LibrarianDashboardLoaded(library: library, stats: stats));
    } catch (e) {
      emit(LibrarianError(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> _onLoadRequests(
    LoadLibrarianRequests event,
    Emitter<LibrarianState> emit,
  ) async {
    emit(const LibrarianLoading());
    try {
      final requests = await _dataSource.getBookRequests();
      emit(LibrarianRequestsLoaded(requests));
    } catch (e) {
      emit(LibrarianError(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> _onAcceptRequest(
    AcceptRequestEvent event,
    Emitter<LibrarianState> emit,
  ) async {
    emit(const LibrarianLoading());
    try {
      await _dataSource.acceptRequest(event.requestId);
      emit(const LibrarianActionSuccess('Request accepted'));
    } catch (e) {
      emit(LibrarianError(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> _onRejectRequest(
    RejectRequestEvent event,
    Emitter<LibrarianState> emit,
  ) async {
    emit(const LibrarianLoading());
    try {
      await _dataSource.rejectRequest(event.requestId, event.reason);
      emit(const LibrarianActionSuccess('Request rejected'));
    } catch (e) {
      emit(LibrarianError(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> _onUpdateRequestStatus(
    UpdateRequestStatusEvent event,
    Emitter<LibrarianState> emit,
  ) async {
    emit(const LibrarianLoading());
    try {
      await _dataSource.updateRequestStatus(event.requestId, event.status);
      emit(const LibrarianActionSuccess('Status updated'));
    } catch (e) {
      emit(LibrarianError(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> _onLoadDonations(
    LoadLibrarianDonations event,
    Emitter<LibrarianState> emit,
  ) async {
    emit(const LibrarianLoading());
    try {
      final donations = await _dataSource.getDonations();
      emit(LibrarianDonationsLoaded(donations));
    } catch (e) {
      emit(LibrarianError(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> _onUpdateDonationStatus(
    UpdateDonationStatusEvent event,
    Emitter<LibrarianState> emit,
  ) async {
    emit(const LibrarianLoading());
    try {
      await _dataSource.updateDonationStatus(event.donationId, event.status);
      emit(const LibrarianActionSuccess('Donation status updated'));
    } catch (e) {
      emit(LibrarianError(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> _onSchedulePickup(
    SchedulePickupEvent event,
    Emitter<LibrarianState> emit,
  ) async {
    emit(const LibrarianLoading());
    try {
      await _dataSource.scheduleDonationPickup(event.donationId, event.data);
      emit(const LibrarianActionSuccess('Pickup scheduled'));
    } catch (e) {
      emit(LibrarianError(ErrorHandler.getErrorMessage(e)));
    }
  }
}
