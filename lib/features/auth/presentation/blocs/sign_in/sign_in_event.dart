part of 'sign_in_bloc.dart';

sealed class SignInEvent extends Equatable {
  const SignInEvent();
}

final class SignInRequest extends SignInEvent {
  final String email;
  final String password;

  const SignInRequest({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

final class SendOtpRequested extends SignInEvent {
  final String email;

  const SendOtpRequested(this.email);

  @override
  List<Object?> get props => [email];
}

final class VerifyOtpRequested extends SignInEvent {
  final String email;
  final String otp;

  const VerifyOtpRequested({required this.email, required this.otp});

  @override
  List<Object?> get props => [email, otp];
}

final class ChangePasswordRequested extends SignInEvent {
  final String email;
  final String code;
  final String newPassword;

  const ChangePasswordRequested({
    required this.email,
    required this.code,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [email, code, newPassword];
}