part of 'sign_in_bloc.dart';

sealed class SignInState extends Equatable {
  const SignInState();
}

final class SignInInitial extends SignInState {
  @override
  List<Object> get props => [];
}

final class SignInLoading extends SignInState {
  @override
  List<Object> get props => [];
}

final class SignInSuccess extends SignInState {
  final AppUser user;

  const SignInSuccess(this.user);

  @override
  List<Object> get props => [user];
}

final class SignInFailure extends SignInState {
  final String errorMessage;

  /// True when the failure is the backend's "email not verified" 403.
  final bool isEmailNotVerified;

  /// Email surfaced by the backend for the unverified account (if any).
  final String? email;

  const SignInFailure(
    this.errorMessage, {
    this.isEmailNotVerified = false,
    this.email,
  });

  @override
  List<Object?> get props => [errorMessage, isEmailNotVerified, email];
}

final class OtpSentSuccess extends SignInState {
  final String email;

  const OtpSentSuccess(this.email);

  @override
  List<Object> get props => [email];
}

final class OtpVerifiedSuccess extends SignInState {
  @override
  List<Object> get props => [];
}

final class PasswordChangedSuccess extends SignInState {
  @override
  List<Object> get props => [];
}
