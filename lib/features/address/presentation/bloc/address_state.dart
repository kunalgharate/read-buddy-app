part of 'address_bloc.dart';

sealed class AddressState extends Equatable {
  const AddressState();
  @override
  List<Object?> get props => [];
}

final class AddressInitial extends AddressState {}

final class AddressLoading extends AddressState {}

final class AddressesLoaded extends AddressState {
  final List<AddressEntity> addresses;
  const AddressesLoaded(this.addresses);
  @override
  List<Object?> get props => [addresses];
}

final class AddressCreated extends AddressState {
  final AddressEntity address;
  const AddressCreated(this.address);
  @override
  List<Object?> get props => [address];
}

final class AddressUpdated extends AddressState {
  final AddressEntity address;
  const AddressUpdated(this.address);
  @override
  List<Object?> get props => [address];
}

final class AddressDeleted extends AddressState {}

final class AddressError extends AddressState {
  final String message;
  const AddressError(this.message);
  @override
  List<Object?> get props => [message];
}
