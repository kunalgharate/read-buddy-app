part of 'permission_bloc.dart';

abstract class PermissionEvent extends Equatable {
  const PermissionEvent();

  @override
  List<Object?> get props => [];
}

class LoadPermissionsEvent extends PermissionEvent {}

class RequestPermissionEvent extends PermissionEvent {
  final AppPermission permission;

  const RequestPermissionEvent(this.permission);

  @override
  List<Object?> get props => [permission];
}

class RequestAllPermissionsEvent extends PermissionEvent {}

class CheckPermissionStatusEvent extends PermissionEvent {}

class OpenAppSettingsEvent extends PermissionEvent {}
