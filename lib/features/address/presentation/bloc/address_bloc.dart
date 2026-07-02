import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:read_buddy_app/core/utils/error_handler.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/usecases/address_usecases.dart';

part 'address_event.dart';
part 'address_state.dart';

class AddressBloc extends Bloc<AddressEvent, AddressState> {
  final GetAddresses _getAddresses;
  final CreateAddress _createAddress;
  final UpdateAddress _updateAddress;
  final DeleteAddress _deleteAddress;

  AddressBloc({
    required GetAddresses getAddresses,
    required CreateAddress createAddress,
    required UpdateAddress updateAddress,
    required DeleteAddress deleteAddress,
  })  : _getAddresses = getAddresses,
        _createAddress = createAddress,
        _updateAddress = updateAddress,
        _deleteAddress = deleteAddress,
        super(AddressInitial()) {
    on<LoadAddresses>(_onLoadAddresses);
    on<CreateAddressEvent>(_onCreateAddress);
    on<UpdateAddressEvent>(_onUpdateAddress);
    on<DeleteAddressEvent>(_onDeleteAddress);
  }

  Future<void> _onLoadAddresses(
    LoadAddresses event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressLoading());
    try {
      final addresses = await _getAddresses();
      emit(AddressesLoaded(addresses));
    } catch (e) {
      emit(AddressError(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> _onCreateAddress(
    CreateAddressEvent event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressLoading());
    try {
      final address = await _createAddress(event.data);
      emit(AddressCreated(address));
    } catch (e) {
      emit(AddressError(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> _onUpdateAddress(
    UpdateAddressEvent event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressLoading());
    try {
      final address = await _updateAddress(event.id, event.data);
      emit(AddressUpdated(address));
    } catch (e) {
      emit(AddressError(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> _onDeleteAddress(
    DeleteAddressEvent event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressLoading());
    try {
      await _deleteAddress(event.id);
      emit(AddressDeleted());
    } catch (e) {
      emit(AddressError(ErrorHandler.getErrorMessage(e)));
    }
  }
}
