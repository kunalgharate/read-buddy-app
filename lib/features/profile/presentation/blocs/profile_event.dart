part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfileEvent extends ProfileEvent {}

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

class UpdateProfilePhotoEvent extends ProfileEvent {
  final PhotoSource source;

  const UpdateProfilePhotoEvent({required this.source});

  @override
  List<Object?> get props => [source];
}

class RefreshProfileEvent extends ProfileEvent {}
