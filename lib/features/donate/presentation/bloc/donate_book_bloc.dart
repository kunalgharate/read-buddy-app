import 'package:flutter/foundation.dart';
import 'package:read_buddy_app/features/donate/domain/entities/book_donation_request.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:read_buddy_app/features/library/domain/entities/library_entity.dart';
import 'package:read_buddy_app/features/library/domain/usecases/library_usecases.dart';
import 'package:read_buddy_app/features/donate/domain/entities/donation_stats.dart';
import 'package:read_buddy_app/features/donate/domain/usecases/get_donation_stats.dart';
import 'package:read_buddy_app/features/donate/domain/usecases/create_book_donation.dart';
import 'package:read_buddy_app/features/donate/domain/usecases/upload_receipt.dart';
import 'package:read_buddy_app/core/utils/error_handler.dart';

part 'donate_book_event.dart';
part 'donate_book_state.dart';

class DonateBookBloc extends Bloc<DonateBookEvent, DonateBookState> {
  final GetDonationStats _getDonationStats;
  final GetLibraryDetails _getLibraryDetails;
  final GetSuperLibraries _getSuperLibraries;
  final CreateBookDonation _createBookDonation;
  final UploadReceipt _uploadReceipt;

  DonateBookBloc({
    required GetDonationStats getDonationStats,
    required GetLibraryDetails getLibraryDetails,
    required GetSuperLibraries getSuperLibraries,
    required CreateBookDonation createBookDonation,
    required UploadReceipt uploadReceipt,
  })  : _getDonationStats = getDonationStats,
        _getLibraryDetails = getLibraryDetails,
        _getSuperLibraries = getSuperLibraries,
        _createBookDonation = createBookDonation,
        _uploadReceipt = uploadReceipt,
        super(DonateBookInitial()) {
    on<LoadDonationStats>(_onLoadDonationStats);
    on<LoadNearestLibraries>(_onLoadNearestLibraries);
    on<SubmitBookDonationEvent>(_onSubmitBookDonation);
    on<UploadDonationReceiptEvent>(_onUploadReceipt);
  }

  Future<void> _onLoadDonationStats(
    LoadDonationStats event,
    Emitter<DonateBookState> emit,
  ) async {
    if (state is DonateBookLoading) return;
    emit(DonateBookLoading());
    try {
      final stats = await _getDonationStats();
      emit(DonationStatsLoaded(stats));
    } catch (error) {
      emit(DonateBookError(ErrorHandler.getErrorMessage(error)));
    }
  }

  Future<void> _onLoadNearestLibraries(
    LoadNearestLibraries event,
    Emitter<DonateBookState> emit,
  ) async {
    emit(DonateBookLoading());
    try {
      final libraries = await _getLibraryDetails();
      if (libraries.isEmpty) {
        // Fallback to super libraries if none available
        final superLibraries = await _getSuperLibraries();
        emit(NearestLibrariesLoaded(superLibraries));
      } else {
        emit(NearestLibrariesLoaded(libraries));
      }
    } catch (error) {
      emit(DonateBookError(ErrorHandler.getErrorMessage(error)));
    }
  }

  Future<void> _onSubmitBookDonation(
    SubmitBookDonationEvent event,
    Emitter<DonateBookState> emit,
  ) async {
    if (kDebugMode) {
      print('📤 [DonateBookBloc] Submitting Book Donation...');
      print('   Type: ${event.request.fulfillmentType}');
    }
    emit(DonateBookLoading());
    try {
      await _createBookDonation(event.request);
      if (kDebugMode) print('✅ [DonateBookBloc] Donation Created Successfully');
      emit(BookDonationCreated());
    } catch (error) {
      if (kDebugMode) print('❌ [DonateBookBloc] Donation Failed: $error');
      emit(DonateBookError(ErrorHandler.getErrorMessage(error)));
    }
  }

  Future<void> _onUploadReceipt(
    UploadDonationReceiptEvent event,
    Emitter<DonateBookState> emit,
  ) async {
    emit(DonateBookLoading());
    try {
      await _uploadReceipt(event.donationId, event.formData);
      emit(ReceiptUploaded());
    } catch (error) {
      emit(DonateBookError(ErrorHandler.getErrorMessage(error)));
    }
  }
}
