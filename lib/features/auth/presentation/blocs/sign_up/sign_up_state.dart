part of 'sign_up_bloc.dart';

@immutable
sealed class SignUpState {}

class SignUpInitial extends SignUpState {}

class SignUpLoading extends SignUpState {}

/// Which flow produced a [SignUpError], so each screen only reacts to the
/// errors it originated (SignUpBloc is a shared app-wide instance).
enum SignUpErrorSource { register, verifyEmail, resend }

class SignUpSuccess extends SignUpState {
  final String email;
  SignUpSuccess(this.email);
}

class SignUpUserVerified extends SignUpState {
  final AppUser user;
  SignUpUserVerified(this.user);
}

class SignUpError extends SignUpState {
  final String message;
  final bool isUserAlreadyExists;
  final SignUpErrorSource source;

  SignUpError({
    required this.message,
    this.isUserAlreadyExists = false,
    this.source = SignUpErrorSource.register,
  });
}

class ResendVerificationEmailSuccess extends SignUpState {
  final String email;
  ResendVerificationEmailSuccess(this.email);
}
