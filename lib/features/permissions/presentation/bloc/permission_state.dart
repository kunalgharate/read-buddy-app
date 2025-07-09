part of 'permission_bloc.dart';

abstract class PermissionState extends Equatable {
  const PermissionState();

  @override
  List<Object?> get props => [];
}

class PermissionInitial extends PermissionState {}

class PermissionLoading extends PermissionState {}

class PermissionLoaded extends PermissionState {
  final List<PermissionInfo> permissions;

  const PermissionLoaded(this.permissions);

  @override
  List<Object?> get props => [permissions];
}

class PermissionUpdated extends PermissionState {
  final List<PermissionInfo> permissions;

  const PermissionUpdated(this.permissions);

  @override
  List<Object?> get props => [permissions];
}

class PermissionAllGranted extends PermissionState {
  final List<PermissionInfo> permissions;

  const PermissionAllGranted(this.permissions);

  @override
  List<Object?> get props => [permissions];
}

class PermissionDenied extends PermissionState {
  final List<PermissionInfo> permissions;
  final AppPermission deniedPermission;

  const PermissionDenied(this.permissions, this.deniedPermission);

  @override
  List<Object?> get props => [permissions, deniedPermission];
}

class PermissionSomeDenied extends PermissionState {
  final List<PermissionInfo> permissions;
  final List<AppPermission> deniedPermissions;

  const PermissionSomeDenied(this.permissions, this.deniedPermissions);

  @override
  List<Object?> get props => [permissions, deniedPermissions];
}

class PermissionPermanentlyDenied extends PermissionState {
  final List<PermissionInfo> permissions;
  final AppPermission deniedPermission;

  const PermissionPermanentlyDenied(this.permissions, this.deniedPermission);

  @override
  List<Object?> get props => [permissions, deniedPermission];
}

class PermissionError extends PermissionState {
  final String message;

  const PermissionError(this.message);

  @override
  List<Object?> get props => [message];
}
