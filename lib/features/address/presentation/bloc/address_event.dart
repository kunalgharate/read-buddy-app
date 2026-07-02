part of 'address_bloc.dart';

sealed class AddressEvent extends Equatable {
  const AddressEvent();
  @override
  List<Object?> get props => [];
}

final class LoadAddresses extends AddressEvent {}

final class CreateAddressEvent extends AddressEvent {
  final Map<String, dynamic> data;
  const CreateAddressEvent(this.data);
  @override
  List<Object?> get props => [data];
}

final class UpdateAddressEvent extends AddressEvent {
  final String id;
  final Map<String, dynamic> data;
  const UpdateAddressEvent(this.id, this.data);
  @override
  List<Object?> get props => [id, data];
}

final class DeleteAddressEvent extends AddressEvent {
  final String id;
  const DeleteAddressEvent(this.id);
  @override
  List<Object?> get props => [id];
}
