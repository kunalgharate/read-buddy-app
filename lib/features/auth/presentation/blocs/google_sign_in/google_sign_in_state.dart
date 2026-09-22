part of 'google_sign_in_bloc.dart';

sealed class GoogleSignInState extends Equatable {
  const GoogleSignInState();

  @override
  List<Object?> get props => [];
}

class GoogleSignInInitial extends GoogleSignInState {}

class GoogleSignInLoading extends GoogleSignInState {}

class GoogleSignInFailure extends GoogleSignInState {
  final String errorMessage;

  const GoogleSignInFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

/// Real Google authentication succeeded — carries the authenticated user
/// (with session tokens) so the LOGIN screen can persist tokens and navigate.
class GoogleSignInAuthenticated extends GoogleSignInState {
  final AppUser user;

  const GoogleSignInAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}
