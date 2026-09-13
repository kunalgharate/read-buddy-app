part of 'google_sign_in_bloc.dart';

sealed class GoogleSignInEvent extends Equatable {
  const GoogleSignInEvent();
}

/// Triggers Google account picker to fetch name/email for sign-up (pre-fill).
class GoogleSignInRequested extends GoogleSignInEvent {
  const GoogleSignInRequested();
  @override
  List<Object?> get props => [];
}

/// Triggers real Google authentication for LOGIN: obtains the Google ID token
/// and exchanges it with the backend for a session (tokens included).
class GoogleLoginRequested extends GoogleSignInEvent {
  const GoogleLoginRequested();
  @override
  List<Object?> get props => [];
}
