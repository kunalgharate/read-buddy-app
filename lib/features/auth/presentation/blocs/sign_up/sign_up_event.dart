part of 'sign_up_bloc.dart';

@immutable
sealed class SignUpEvent {}

class RegisterUserEvent extends SignUpEvent {
  final Map<String, dynamic> userData;
  RegisterUserEvent(this.userData);
}

class VerifyEmailEvent extends SignUpEvent {
  final String email;
  final String code;
  VerifyEmailEvent(this.email, this.code);
}
