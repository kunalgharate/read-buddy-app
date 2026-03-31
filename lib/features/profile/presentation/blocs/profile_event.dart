part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Triggers GET /users/profile
class LoadProfileEvent extends ProfileEvent {}

/// Triggers PATCH /users/update-avatar
class UpdateAvatarEvent extends ProfileEvent {
  final String avatarName;
  const UpdateAvatarEvent(this.avatarName);

  @override
  List<Object?> get props => [avatarName];
}

/// Triggers PUT /users/update-user-info
class UpdateProfileFieldEvent extends ProfileEvent {
  final String field;
  final String value;

  const UpdateProfileFieldEvent({
    required this.field,
    required this.value,
  });

  @override
  List<Object?> get props => [field, value];
}

class RefreshProfileEvent extends ProfileEvent {}