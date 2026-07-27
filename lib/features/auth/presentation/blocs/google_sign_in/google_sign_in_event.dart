part of 'google_sign_in_bloc.dart';

sealed class GoogleSignInEvent extends Equatable {
  const GoogleSignInEvent();
}

/// Triggers Google account picker to fetch name/email for sign-up
class GoogleSignInRequested extends GoogleSignInEvent {
  const GoogleSignInRequested();
  @override
  List<Object?> get props => [];
}
