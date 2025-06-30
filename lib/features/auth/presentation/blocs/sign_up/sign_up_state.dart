part of 'sign_up_bloc.dart';

@immutable
sealed class SignUpState {}


class SignUpInitial extends SignUpState {}

class SignUpLoading extends SignUpState {}

class SignUpSuccess extends SignUpState {
  final AppUser user;
  SignUpSuccess(this.user);
}

class SignUpUserVerified extends SignUpState {
  final AppUser user;
  SignUpUserVerified(this.user);
}

class SignUpError extends SignUpState {
  final String message;
  SignUpError(this.message);
}
