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

class UpdateProfileApiEvent extends ProfileEvent {
  final String? name;
  final String? phno;
  final String? gender;
  final String? dob;
  final String? picture;

  const UpdateProfileApiEvent({
    this.name,
    this.phno,
    this.gender,
    this.dob,
    this.picture,
  });

  @override
  List<Object?> get props => [name, phno, gender, dob, picture];
}

class UpdateProfilePhotoEvent extends ProfileEvent {
  final PhotoSource source;

  const UpdateProfilePhotoEvent({required this.source});

  @override
  List<Object?> get props => [source];
}

class RefreshProfileEvent extends ProfileEvent {}
