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

  const SignInFailure(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
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