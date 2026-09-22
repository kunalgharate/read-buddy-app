part of 'google_sign_in_bloc.dart';

sealed class GoogleSignInEvent extends Equatable {
  const GoogleSignInEvent();
}

/// Triggers real Google authentication for LOGIN: obtains the Google ID token
/// and exchanges it with the backend for a session (tokens included).
class GoogleLoginRequested extends GoogleSignInEvent {
  const GoogleLoginRequested();
  @override
  List<Object?> get props => [];
}
