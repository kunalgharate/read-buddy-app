part of 'google_sign_in_bloc.dart';

sealed class GoogleSignInState extends Equatable {
  const GoogleSignInState();

  @override
  List<Object?> get props => [];
}

class GoogleSignInInitial extends GoogleSignInState {}

class GoogleSignInLoading extends GoogleSignInState {}

/// Google account data fetched successfully — contains name and email
/// to pre-fill the sign-up form. User still needs to set a password.
class GoogleSignUpDataFetched extends GoogleSignInState {
  final String name;
  final String email;

  const GoogleSignUpDataFetched({required this.name, required this.email});

  @override
  List<Object?> get props => [name, email];
}

class GoogleSignInFailure extends GoogleSignInState {
  final String errorMessage;

  const GoogleSignInFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
